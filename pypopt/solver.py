from collections import namedtuple
from pyomo.opt.base import SolverFactory
from pyomo.solvers.plugins.solvers.direct_solver import DirectSolver
from pyomo.solvers.plugins.solvers.persistent_solver import PersistentSolver
from pyutilib.misc import Bunch
from pypopt.pyomo import PyomoNLP
from pypopt._cython import IpoptApplication, SolverReturn, ApplicationReturnStatus
from pyomo.environ import Var
from pyomo.opt.results.results_ import SolverResults
from pyomo.opt.results.solver import TerminationCondition, SolverStatus


ResultSolution = namedtuple('ResultSolution', ['status', 'termination_message', 'termination_condition'])


_return_status_map = {
    SolverReturn.SUCCESS: ResultSolution(
        status=SolverStatus.ok,
        termination_condition=TerminationCondition.optimal,
        termination_message='Ok'
    ),
    SolverReturn.MAXITER_EXCEEDED: ResultSolution(
        status=SolverStatus.ok,
        termination_condition=TerminationCondition.maxIterations,
        termination_message='Ok'
    ),
    SolverReturn.CPUTIME_EXCEEDED: ResultSolution(
        status=SolverStatus.ok,
        termination_condition=TerminationCondition.maxTimeLimit,
        termination_message='Ok'
    ),
    SolverReturn.STOP_AT_TINY_STEP: ResultSolution(
        status=SolverStatus.ok,
        termination_condition=TerminationCondition.minStepLength,
        termination_message='Ok'
    ),
    SolverReturn.STOP_AT_ACCEPTABLE_POINT: ResultSolution(
        status=SolverStatus.ok,
        termination_condition=TerminationCondition.other,
        termination_message='Acceptable Point'
    ),
    SolverReturn.LOCAL_INFEASIBILITY: ResultSolution(
        status=SolverStatus.warning,
        termination_condition=TerminationCondition.infeasible,
        termination_message='Local Infeasibility'
    ),
    SolverReturn.USER_REQUESTED_STOP: ResultSolution(
        status=SolverStatus.aborted,
        termination_condition=TerminationCondition.userInterrupt,
        termination_message='User Requested Stop'
    ),
    SolverReturn.FEASIBLE_POINT_FOUND: ResultSolution(
        status=SolverStatus.ok,
        termination_condition=TerminationCondition.feasible,
        termination_message='Feasible Point Found'
    ),
    SolverReturn.DIVERGING_ITERATES: ResultSolution(
        status=SolverStatus.warning,
        termination_condition=TerminationCondition.other,
        termination_message='Diverging Iterates'
    ),
    SolverReturn.RESTORATION_FAILURE: ResultSolution(
        status=SolverStatus.error,
        termination_condition=TerminationCondition.solverFailure,
        termination_message='Restoration Failure'
    ),
    SolverReturn.ERROR_IN_STEP_COMPUTATION: ResultSolution(
        status=SolverStatus.error,
        termination_condition=TerminationCondition.solverFailure,
        termination_message='Error in Step Computation'
    ),
    SolverReturn.INVALID_NUMBER_DETECTED: ResultSolution(
        status=SolverStatus.error,
        termination_condition=TerminationCondition.solverFailure,
        termination_message='Invalid Number Detected'
    ),
    SolverReturn.TOO_FEW_DEGREES_OF_FREEDOM: ResultSolution(
        status=SolverStatus.error,
        termination_condition=TerminationCondition.solverFailure,
        termination_message='Too Few Degrees of Freedom'
    ),
    SolverReturn.INVALID_OPTION: ResultSolution(
        status=SolverStatus.error,
        termination_condition=TerminationCondition.error,
        termination_message='Invalid Option'
    ),
    SolverReturn.OUT_OF_MEMORY: ResultSolution(
        status=SolverStatus.error,
        termination_condition=TerminationCondition.internalSolverError,
        termination_message='Out of Memory'
    ),
    SolverReturn.INTERNAL_ERROR: ResultSolution(
        status=SolverStatus.error,
        termination_condition=TerminationCondition.internalSolverError,
        termination_message='Internal Error'
    ),
    SolverReturn.UNASSIGNED: ResultSolution(
        status=SolverStatus.error,
        termination_condition=TerminationCondition.error,
        termination_message='Unassigned'
    ),
}


@SolverFactory.register('pypopt_direct', doc='')
class PypoptDirectSolver(DirectSolver):
    def __init__(self, **kwargs):
        if 'type' not in kwargs:
            kwargs['type'] = 'pypopt_direct'
        super().__init__(**kwargs)
        self._solver_model = None
        self._pyomo_model = None
        self._res = None
        self.results = None

    def _apply_solver(self):
        app = IpoptApplication()

        solver_options = app.options()
        status = app.initialize()

        for opt, opt_value in self.options.items():
            if opt == 'max_cpu_time':
                solver_options.set_integer_value(opt, int(opt_value))
            elif isinstance(opt_value, str):
                solver_options.set_string_value(opt, opt_value)
            elif isinstance(opt_value, int):
                solver_options.set_integer_value(opt, opt_value)
            else:
                solver_options.set_numeric_value(opt, opt_value)

        if status.is_error():
            raise RuntimeError('initialize: {}'.format(status.message()))

        res = app.optimize_tnlp(self._solver_model)
        self._res = res
        return Bunch(rc=0, log=None)

    def _postsolve(self):
        res = self._res
        self.results = SolverResults()
        rs = res.return_status()

        result_solution = _return_status_map.get(rs, None)
        if result_solution is None:
            raise ValueError('Invalid return status {}'.format(rs))

        self.results.solver.status = result_solution.status
        self.results.solver.termination_condition = result_solution.termination_condition
        self.results.solver.termination_message = result_solution.termination_message
        self.results.problem.name = self._pyomo_model.name

        self.results.problem.upper_bound = self._solver_model.solution.obj_value
        self.results.problem.lower_bound = None

        self._load_vars()

        return self.results

    def _set_instance(self, model, kwds=None):
        self._solver_model = PyomoNLP(model, active=True, sort=True, descend_into=True)
        self._pyomo_model = model

    def _set_objective(self, obj):
        pass

    def _add_constraint(self, con):
        pass

    def _add_sos_constraint(self, con):
        pass

    def _add_var(self, var):
        pass

    def _get_expr_from_pyomo_repn(self, repn, max_degree=None):
        pass

    def _get_expr_from_pyomo_expr(self, expr, max_degree=None):
        pass

    def _load_vars(self, vars_to_load=None):
        x = self._solver_model.solution.x
        for var, i in self._solver_model.pyomo_to_ipopt_map.items():
            var.value = x[i]

    def warm_start_capable(self):
        return False

    def available(self, exception_flag=True):
        return True


@SolverFactory.register('pypopt_persistent', doc='')
class PypoptPersistentSolver(PersistentSolver, PypoptDirectSolver):
    def __init__(self, **kwargs):
        if 'type' not in kwargs:
            kwargs['type'] = 'pypopt_persistent'
        super().__init__(**kwargs)
        self._solver_model = None
        self._pyomo_model = None
        self._res = None
        self.results = None

    def update_var(self, var):
        # see PR #366 for discussion about handling indexed
        # objects and keeping compatibility with the
        # pyomo.kernel objects
        #if var.is_indexed():
        #    for child_var in var.values():
        #        self.compile_var(child_var)
        #    return
        if var not in self._solver_model.pyomo_to_ipopt_map:
            raise ValueError('The Var provided to compile_var needs to be added first: {0}'.format(var))
        ipopt_var_idx = self._solver_model.pyomo_to_ipopt_map[var]

        vtype = self._cplex_vtype_from_var(var)
        if var.is_fixed():
            lb = var.value
            ub = var.value
        else:
            lb = -self._cplex.infinity
            ub = self._cplex.infinity
            if var.has_lb():
                lb = value(var.lb)
            if var.has_ub():
                ub = value(var.ub)
        self._solver_model.variables.set_lower_bounds(cplex_var, lb)
        self._solver_model.variables.set_upper_bounds(cplex_var, ub)
        self._solver_model.variables.set_types(cplex_var, vtype)

    def write(self, filename, filetype=''):
        """
        Write the model to a file (e.g., and lp file).

        Parameters
        ----------
        filename: str
            Name of the file to which the model should be written.
        filetype: str
            The file type (e.g., lp).
        """
        self._solver_model.write(filename, filetype=filetype)
