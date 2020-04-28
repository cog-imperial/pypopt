# Copyright 2020 Francesco Ceccon
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

import numpy as np
from collections import namedtuple
from cppyad import (
    build_adfun_from_model, SparseJacobianWork, SparseHessianWork
)

from pypopt._cython import TNLP, NLPInfo


_ipopt_index_t = np.int32


PyomoNLPSolution = namedtuple(
    'PyomoNLPSolution', ['x', 'z_l', 'z_u', 'g', 'lambda_', 'obj_value']
)


class PyomoNLP(TNLP):
    def __init__(self, model, active=True, sort=False, descend_into=True):
        super().__init__()

        adfun, nx, nf, ng, x_init, x_lb, x_ub, g_lb, g_ub, pyomo_to_ipopt_map = \
            build_adfun_from_model(model, active=active, sort=sort, descend_into=descend_into)

        self._adfun = adfun
        self._nx = nx
        self._nf = nf
        self._ng = ng

        self._x_init = x_init
        self._x_lb = x_lb
        self._x_ub = x_ub

        self._g_lb = g_lb
        self._g_ub = g_ub

        self._cached_x = x_init.copy()
        self._cached_y = np.zeros(ng, dtype=np.float64)
        self._cached_obj_factor = 0.0

        self._fg0 = adfun.forward(0, self._x_init)
        self._w = np.zeros(self._nf + self._ng, dtype=np.float64)
        self._grad = np.zeros(self._nx, dtype=np.float64)

        (
            jac_pat, jac_row, jac_col, jac_row_ipopt, jac_col_ipopt,
            jac_skip_ipopt, grad_col_ipopt
        ) = _jacobian_structure(adfun, nx, nf, ng)
        self._jac_pat = jac_pat
        self._jac_row = jac_row
        self._jac_col = jac_col
        self._jac_row_ipopt = jac_row_ipopt
        self._jac_col_ipopt = jac_col_ipopt
        self._jac_skip_ipopt = jac_skip_ipopt
        self._jac_work = SparseJacobianWork()
        self._jac = np.zeros_like(self._jac_row, dtype=np.float64)
        self._grad_col_ipopt = grad_col_ipopt

        hes_pat, hes_row, hes_col = _hessian_structure(adfun, nx, nf, ng)
        self._hes_pat = hes_pat
        self._hes_row = hes_row
        self._hes_col = hes_col
        self._hes_work = SparseHessianWork()
        self._hes = np.zeros_like(self._hes_row, dtype=np.float64)

        self._invalidate_dual_caches()
        self._invalidate_primal_caches()

        self.pyomo_to_ipopt_map = pyomo_to_ipopt_map
        self.solution = None

    def _invalidate_primal_caches(self):
        self._fg0_cached = False
        self._jac_cached = False

    def _invalidate_dual_caches(self):
        self._hes_cached = False

    def _cache_new_x(self, x):
        self._invalidate_primal_caches()
        np.copyto(self._cached_x, x)

    def _cache_new_y(self, obj_factor, lambda_):
        self._invalidate_dual_caches()
        self._cached_obj_factor = obj_factor
        np.copyto(self._cached_y, lambda_)

    def _compute_fg0(self):
        if self._fg0_cached:
            return
        self._fg0 = self._adfun.forward(0, self._cached_x)
        self._fg0_cached = True

    def _compute_jacobian(self):
        if self._jac_cached:
            return
        self._adfun.sparse_jacobian_reverse(
            self._cached_x, self._jac_pat, self._jac_row, self._jac_col,
            self._jac, self._jac_work
        )
        self._jac_cached = True

    def _compute_hessian(self):
        if self._hes_cached:
            return
        nf = self._nf
        ng = self._ng
        for i in range(nf):
            self._w[i] = self._cached_obj_factor
        for i in range(ng):
            self._w[nf+i] = self._cached_y[i]
        self._adfun.sparse_hessian(
            self._cached_x, self._w, self._hes_pat, self._hes_row,
            self._hes_col, self._hes, self._hes_work
        )
        self._hes_cached = True

    def get_nlp_info(self):
        return NLPInfo(
            n=self._nx,
            m=self._ng,
            nnz_jac=self._jac_row_ipopt.shape[0],
            nnz_hess=self._hes_row.shape[0],
        )

    def get_bounds_info(self, x_l, x_u, g_l, g_u):
        np.copyto(np.asarray(x_l), self._x_lb, casting='no')
        np.copyto(np.asarray(x_u), self._x_ub, casting='no')
        np.copyto(np.asarray(g_l), self._g_lb, casting='no')
        np.copyto(np.asarray(g_u), self._g_ub, casting='no')
        return True

    def get_starting_point(self, init_x, x, init_z, z_l, z_u, init_lambda,
                           lambda_):
        assert init_x
        assert not init_z
        assert not init_lambda
        np.copyto(np.asarray(x), self._x_init, casting='no')
        return True

    def eval_f(self, x, new_x):
        if new_x:
            self._cache_new_x(x)
        self._compute_fg0()
        sum = 0.0
        for i in range(self._nf):
            sum += self._fg0[i]
        return sum

    def eval_grad_f(self, x, new_x, grad_f):
        if new_x:
            self._cache_new_x(x)
        self._compute_jacobian()
        jac = self._jac
        for i, j in enumerate(self._grad_col_ipopt):
            grad_f[j] = jac[i]
        return True

    def eval_g(self, x, new_x, g):
        if new_x:
            self._cache_new_x(x)
        self._compute_fg0()
        np.copyto(np.asarray(g), self._fg0[self._nf:], casting='no')
        return True

    def get_jac_g_structure(self, row, col):
        np.copyto(np.asarray(row), self._jac_row_ipopt.astype(_ipopt_index_t))
        np.copyto(np.asarray(col), self._jac_col_ipopt.astype(_ipopt_index_t))
        return True

    def eval_jac_g(self, x, new_x, values):
        if new_x:
            self._cache_new_x(x)
        self._compute_jacobian()
        np.copyto(
            np.asarray(values),
            self._jac[self._jac_skip_ipopt-1:],
            casting='no'
        )
        return True

    def get_h_structure(self, row, col):
        np.copyto(np.asarray(row), self._hes_row.astype(_ipopt_index_t))
        np.copyto(np.asarray(col), self._hes_col.astype(_ipopt_index_t))
        return True

    def eval_h(self, x, new_x, obj_factor, lambda_, new_lambda, values):
        if new_x:
            self._cache_new_x(x)
        if new_lambda:
            self._cache_new_y(obj_factor, lambda_)
        self._compute_hessian()
        np.copyto(np.asarray(values), self._hes, casting='no')
        return True

    def finalize_solution(self, x, z_l, z_u, g, lambda_, obj_value):
        self.solution = PyomoNLPSolution(
            np.asarray(x).copy(),
            np.asarray(z_l).copy(),
            np.asarray(z_u).copy(),
            np.asarray(g).copy(),
            np.asarray(lambda_).copy(),
            obj_value,
        )


def _jacobian_structure(adfun, nx, nf, ng):
    m = nf + ng
    r = np.eye(m, dtype=np.bool).reshape(m*m)

    jac_pat = adfun.sparse_jacobian_pattern_reverse(m, r)

    jac_row = []
    jac_col = []
    jac_row_ipopt = []
    jac_col_ipopt = []
    grad_col_ipopt = []
    jac_skip_ipopt = None
    skip_count = 0
    for i in range(m):
        for j in range(nx):
            if jac_pat[i * nx + j]:
                skip_count += 1
                jac_row.append(i)
                jac_col.append(j)
                if i >= nf:
                    if jac_skip_ipopt is None:
                        jac_skip_ipopt = skip_count
                    jac_row_ipopt.append(i - nf)
                    jac_col_ipopt.append(j)
                else:
                    grad_col_ipopt.append(j)

    return (
        np.array(jac_pat, dtype=np.bool),
        np.array(jac_row, dtype=np.uint64),
        np.array(jac_col, dtype=np.uint64),
        np.array(jac_row_ipopt, dtype=_ipopt_index_t),
        np.array(jac_col_ipopt, dtype=_ipopt_index_t),
        jac_skip_ipopt,
        np.array(grad_col_ipopt, dtype=_ipopt_index_t),
    )


def _hessian_structure(adfun, nx, nf, ng):
    r = np.eye(nx, dtype=np.bool).reshape(nx*nx)
    s = np.ones(nx, dtype=np.bool)

    adfun.sparse_jacobian_pattern_forward(nx, r)
    hes_pat = adfun.sparse_hessian_pattern_reverse(nx, s, True)

    hes_row = []
    hes_col = []
    for i in range(nx):
        for j in range(nx):
            if hes_pat[i * nx + j]:
                if j <= i:
                    hes_row.append(i)
                    hes_col.append(j)
    return (
        np.array(hes_pat, dtype=np.bool),
        np.array(hes_row, dtype=np.uint64),
        np.array(hes_col, dtype=np.uint64),
    )
