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

cimport pypopt.ipopt as ip


cdef cppclass WrapperTNLP(ip.TNLP):
    TNLP owner

    WrapperTNLP(TNLP owner_):
        this.owner = owner_

    bool get_nlp_info(ip.Index &n, ip.Index &m, ip.Index &nnz_jac_g,
                      ip.Index &nnz_h_lag, ip.IndexStyleEnum &index_style):
        info = owner.get_nlp_info()
        if info is None:
            return False
        (&n)[0] = info.n
        (&m)[0] = info.m
        (&nnz_jac_g)[0] = info.nnz_jac
        (&nnz_h_lag)[0] = info.nnz_hess
        (&index_style)[0] = info.index_style
        return True

    bool get_bounds_info(ip.Index n, ip.Number *x_l, ip.Number *x_u,
                         ip.Index m, ip.Number *g_l, ip.Number *g_u):
        cdef ip.Number[:] py_x_l
        cdef ip.Number[:] py_x_u
        cdef ip.Number[:] py_g_l
        cdef ip.Number[:] py_g_u

        if n:
            py_x_l = <ip.Number[:n]>x_l
            py_x_u = <ip.Number[:n]>x_u
        else:
            py_x_l = None
            py_x_u = None

        if m:
            py_g_l = <ip.Number[:m]>g_l
            py_g_u = <ip.Number[:m]>g_u
        else:
            py_g_l = None
            py_g_u = None

        return owner.get_bounds_info(py_x_l, py_x_u, py_g_l, py_g_u)

    bool get_starting_point(ip.Index n, bool init_x, ip.Number *x,
                            bool init_z, ip.Number *z_l, ip.Number *z_u,
                            ip.Index m, bool init_lambda, ip.Number *lambda_):
        cdef ip.Number[:] py_x
        cdef ip.Number[:] py_z_l
        cdef ip.Number[:] py_z_u
        cdef ip.Number[:] py_lambda

        if init_x:
            py_x = <ip.Number[:n]>x
        else:
            py_x = None

        if init_z:
            py_z_l = <ip.Number[:n]>z_l
            py_z_u = <ip.Number[:n]>z_u
        else:
            py_z_l = py_z_u = None

        if init_lambda:
            py_lambda = <ip.Number[:m]>lambda_
        else:
            py_lambda = None

        return owner.get_starting_point(
            init_x, py_x, init_z, py_z_l, py_z_u, init_lambda, py_lambda
        )

    bool eval_f(ip.Index n, const ip.Number *x, bool new_x, ip.Number &obj_val):
        cdef ip.Number[:] py_x = <ip.Number[:n]>x
        py_obj_val = owner.eval_f(py_x, new_x)
        (&obj_val)[0] = py_obj_val
        return True

    bool eval_grad_f(ip.Index n, const ip.Number *x, bool new_x,
                     ip.Number *grad_f):
        cdef ip.Number[:] py_x = <ip.Number[:n]>x
        cdef ip.Number[:] py_grad_f = <ip.Number[:n]>grad_f
        return owner.eval_grad_f(py_x, new_x, py_grad_f)

    bool eval_g(ip.Index n, const ip.Number *x, bool new_x, ip.Index m,
                ip.Number *g):
        cdef ip.Number[:] py_x = <ip.Number[:n]>x
        cdef ip.Number[:] py_g
        if m:
            py_g = <ip.Number[:m]>g
        else:
            py_g = None
        return owner.eval_g(py_x, new_x, py_g)

    bool eval_jac_g(ip.Index n, const ip.Number *x, bool new_x, ip.Index m,
                    ip.Index nele_jac, ip.Index *row, ip.Index *col,
                    ip.Number *values):
        cdef ip.Index[:] py_row
        cdef ip.Index[:] py_col
        cdef ip.Number[:] py_x
        cdef ip.Number[:] py_values

        if values == NULL:
            if nele_jac:
                py_row = <ip.Index[:nele_jac]>row
                py_col = <ip.Index[:nele_jac]>col
            else:
                py_row = py_col = None
            return owner.get_jac_g_structure(py_row, py_col)
        else:
            py_x = <ip.Number[:n]>x
            if nele_jac:
                py_values = <ip.Number[:nele_jac]>values
            else:
                py_values = None
            return owner.eval_jac_g(py_x, new_x, py_values)

    bool eval_h(ip.Index n, const ip.Number *x, bool new_x, ip.Number
                obj_factor, ip.Index m, const ip.Number *lambda_,
                bool new_lambda, ip.Index nele_hess, ip.Index *row,
                ip.Index *col, ip.Number *values):
        cdef ip.Index[:] py_row
        cdef ip.Index[:] py_col
        cdef ip.Number[:] py_x
        cdef ip.Number[:] py_values
        cdef ip.Number[:] py_lambda

        if values == NULL:
            py_row = <ip.Index[:nele_hess]>row
            py_col = <ip.Index[:nele_hess]>col
            return owner.get_h_structure(py_row, py_col)
        else:
            py_x = <ip.Number[:n]>x
            if m:
                py_lambda = <ip.Number[:m]>lambda_
            else:
                py_lambda = None
            py_values = <ip.Number[:nele_hess]>values
            return owner.eval_h(
                py_x, new_x, obj_factor, py_lambda, new_lambda, py_values
            )

    void finalize_solution(ip.SolverReturn status, ip.Index n,
                           const ip.Number *x, const ip.Number *z_l,
                           const ip.Number *z_u, ip.Index m, const ip.Number *g,
                           const ip.Number *lambda_, ip.Number obj_value,
                           const ip.IpoptData *ip_data,
                           ip.IpoptCalculatedQuantities *ip_cq):
        cdef ip.Number[:] py_x = <ip.Number[:n]>x
        cdef ip.Number[:] py_z_l = <ip.Number[:n]>z_l
        cdef ip.Number[:] py_z_u = <ip.Number[:n]>z_u
        cdef ip.Number[:] py_g
        cdef ip.Number[:] py_lambda

        if m:
            py_g = <ip.Number[:m]>g
            py_lambda = <ip.Number[:m]>lambda_
        else:
            py_g = None
            py_lambda = None

        owner.finalize_solution(
            py_x, py_z_l, py_z_u, py_g, py_lambda, obj_value
        )
