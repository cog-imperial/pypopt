# Copyright 2018 Francesco Ceccon
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

cpdef enum IndexStyle:
    C_STYLE
    FORTRAN_STYLE


cdef class NLPInfo:
    cdef readonly ip.Index n, m, nnz_jac, nnz_hess
    cdef readonly ip.IndexStyleEnum index_style

    def __init__(self, n, m, nnz_jac, nnz_hess, index_style=None):
        cdef ip.IndexStyleEnum c_index_style = ip.IndexStyleEnum.C_STYLE
        self.n = n
        self.m = m
        self.nnz_jac = nnz_jac
        self.nnz_hess = nnz_hess
        if index_style is not None:
            c_index_style = index_style
        self.index_style = c_index_style


cdef class TNLP:
    cpdef get_nlp_info(self):
        pass

    cpdef get_bounds_info(self, x_l, x_u, g_l, g_u):
        pass

    cpdef get_starting_point(self, init_x, x, init_z, z_l, z_u, init_lambda, lambda_):
        pass

    cpdef eval_f(self, x, new_x):
        pass

    cpdef eval_grad_f(self, x, new_x, grad_f):
        pass

    cpdef eval_g(self, x, new_x, g):
        pass

    cpdef get_jac_g_structure(self, row, col):
        pass

    cpdef eval_jac_g(self, x, new_x, values):
        pass

    cpdef get_h_structure(self, row, col):
        pass

    cpdef eval_h(self, x, new_x, obj_factor, lambda_, new_lambda, values):
        pass

    cpdef finalize_solution(self, x, z_l, z_u, g, lambda_, obj_value):
        pass
