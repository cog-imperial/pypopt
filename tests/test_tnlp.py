# pylint: skip-file
import pytest
import numpy as np
from numpy.testing import assert_array_almost_equal
from pypopt import IpoptApplication, TNLP, IndexStyle, NLPInfo
from pypopt.__version__ import __version__


class Hs071NLP(TNLP):
    def __init__(self):
        self.n = 4
        self.m = 2
        self.nnz_jac = 8
        self.nnz_hess = 10
        self.nnz_h = self.nnz_hess

        self.solution = None
        self.objective = None

    def get_nlp_info(self):
        return NLPInfo(
            n=self.n,
            m=self.m,
            nnz_jac=self.nnz_jac,
            nnz_hess=self.nnz_hess,
        )

    def get_bounds_info(self, x_l, x_u, g_l, g_u):
        n = x_l.shape[0]
        for i in range(n):
            x_l[i] = 1.0
            x_u[i] = 5.0

        g_l[0] = 25
        g_u[0] = 2e19

        g_l[1] = 40
        g_u[1] = 40
        return True

    def get_starting_point(self, init_x, x, init_z, z_l, z_u, init_lambda, lambda_):
        assert init_x
        assert not init_z
        assert not init_lambda

        x[0] = 1.0
        x[1] = 5.0
        x[2] = 5.0
        x[3] = 1.0
        return True

    def eval_f(self, x, new_x):
        return x[0] * x[3] * (x[0] + x[1] + x[2]) + x[2]

    def eval_grad_f(self, x, new_x, grad_f):
        grad_f[0] = x[0] * x[3] + x[3] * (x[0] + x[1] + x[2]);
        grad_f[1] = x[0] * x[3];
        grad_f[2] = x[0] * x[3] + 1;
        grad_f[3] = x[0] * (x[0] + x[1] + x[2]);
        return True

    def eval_g(self, x, new_x, g):
        g[0] = x[0] * x[1] * x[2] * x[3];
        g[1] = x[0]*x[0] + x[1]*x[1] + x[2]*x[2] + x[3]*x[3];
        return True

    def get_jac_g_structure(self, row, col):
        row[0] = 0
        col[0] = 0
        row[1] = 0
        col[1] = 1
        row[2] = 0
        col[2] = 2
        row[3] = 0
        col[3] = 3
        row[4] = 1
        col[4] = 0
        row[5] = 1
        col[5] = 1
        row[6] = 1
        col[6] = 2
        row[7] = 1
        col[7] = 3
        return True

    def eval_jac_g(self, x, new_x, values):
        values[0] = x[1]*x[2]*x[3]
        values[1] = x[0]*x[2]*x[3]
        values[2] = x[0]*x[1]*x[3]
        values[3] = x[0]*x[1]*x[2]

        values[4] = 2*x[0]
        values[5] = 2*x[1]
        values[6] = 2*x[2]
        values[7] = 2*x[3]
        return True

    def get_h_structure(self, row, col):
        idx = 0
        for i in range(self.n):
            for j in range(i+1):
                row[idx] = i
                col[idx] = j
                idx += 1
        return True

    def eval_h(self, x, new_x, obj_factor, lambda_, new_lambda, values):
        values[0] = obj_factor * (2*x[3])
        values[1] = obj_factor * (x[3])
        values[2] = 0.0
        values[3] = obj_factor * (x[3])
        values[4] = 0.0
        values[5] = 0.0
        values[6] = obj_factor * (2*x[0] + x[1] + x[2])
        values[7] = obj_factor * (x[0])
        values[8] = obj_factor * (x[0])
        values[9] = 0.0


        # add the portion for the first constraint
        values[1] += lambda_[0] * (x[2] * x[3])
        values[3] += lambda_[0] * (x[1] * x[3])
        values[4] += lambda_[0] * (x[0] * x[3])
        values[6] += lambda_[0] * (x[1] * x[2])
        values[7] += lambda_[0] * (x[0] * x[2])
        values[8] += lambda_[0] * (x[0] * x[1])

        # add the portion for the second constraint
        values[0] += lambda_[1] * 2
        values[2] += lambda_[1] * 2
        values[5] += lambda_[1] * 2
        values[9] += lambda_[1] * 2
        return True

    def finalize_solution(self, x, z_l, z_u, g, lambda_, obj_value):
        self.solution = np.array(x)
        self.objective = obj_value


def test_tnlp():
    app = IpoptApplication()

    status = app.initialize()
    if status.is_error():
        raise RuntimeError('initialize: {}'.format(status.message()))

    hs = Hs071NLP()
    res = app.optimize_tnlp(hs)
    expected_solution = np.array([1.000, 4.74299963, 3.82114998, 1.37940829])
    assert_array_almost_equal(hs.solution, expected_solution)
