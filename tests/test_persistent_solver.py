import pytest
import pyomo.environ as pe
from pyomo.solvers.plugins.solvers.persistent_solver import PersistentSolver
import numpy as np
from .conftest import small_model_hs071, model_with_n_variables
from pypopt.solver import PypoptDirectSolver, PypoptPersistentSolver


def check_hs071_result(result, small_model):
    assert result.solver.status == pe.SolverStatus.ok
    assert result.solver.termination_condition == pe.TerminationCondition.optimal

    expected_solution = np.array([1.000, 4.74299963, 3.82114998, 1.37940829])
    for i, expected in enumerate(expected_solution):
        np.testing.assert_almost_equal(pe.value(small_model.x[i]), expected)
    np.testing.assert_almost_equal(pe.value(small_model.obj), 17.014017257)


def test_direct_produce_correct_solution(small_model_hs071):
    solver = pe.SolverFactory('pypopt_direct')
    result = solver.solve(small_model_hs071)
    check_hs071_result(result, small_model_hs071)


def test_persistent_produce_correct_solution(small_model_hs071):
    solver = pe.SolverFactory('pypopt_persistent')
    solver.set_instance(small_model_hs071)
    result = solver.solve(small_model_hs071)
    check_hs071_result(result, small_model_hs071)


def _solve_n_times(solver, model, n):
    result = None
    for _ in range(n):
        result = solver.solve(model)
    return result

@pytest.mark.parametrize('num_var', [10, 30, 100])
@pytest.mark.parametrize('solve_n_times', [1, 5, 10])
@pytest.mark.parametrize('solver', ['ipopt', 'pypopt_direct', 'pypopt_persistent'])
def test_ipopt_base_performance(benchmark, num_var, solve_n_times, solver):
    solver = pe.SolverFactory(solver)
    model = model_with_n_variables(num_var)
    if isinstance(solver, PersistentSolver):
        solver.set_instance(model)
    result = benchmark(_solve_n_times, solver, model, solve_n_times)
    assert result.solver.status == pe.SolverStatus.ok
    assert result.solver.termination_condition == pe.TerminationCondition.optimal