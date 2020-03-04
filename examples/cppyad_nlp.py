import pyomo.environ as pe

from pypopt import IpoptApplication, PyomoNLP
from pypopt.__version__ import __version__


def get_pyomo_model():
    m = pe.ConcreteModel()
    target = 10
    maxassets = 3
    mean = [8, 9, 12, 7]
    v = [[ 4,  3, -1,  0],
         [ 3,  6,  1,  0],
         [-1,  1, 10,  0],
         [ 0,  0,  0,  0]]

    m.I = range(4)
    m.x = pe.Var(m.I, initialize=0.0, bounds=(0, None))
    m.variance = pe.Var()
    m.active_ = pe.Var(m.I, domain=pe.Binary, initialize=0)

    m.fsum = pe.Constraint(expr=sum(m.x[i] for i in m.I) == 1.0)
    m.dmean = pe.Constraint(expr=sum(m.x[i]*mean[i] for i in m.I) == target)
    @m.Constraint(m.I)
    def setindic(m, i):
        return m.x[i] <= m.active_[i]
    m.maxactive = pe.Constraint(expr=sum(m.active_[i] for i in m.I) <= maxassets)

    m.objective = pe.Objective(expr=sum(m.x[i] * sum(m.x[j] * v[i][j] for j in m.I) for i in m.I), sense=pe.minimize)

    return m


def solve(model):
    app = IpoptApplication()

    opts = app.options()
    opts.set_string_value('derivative_test', 'second-order')
    opts.set_numeric_value('tol', 1e-7)

    status = app.initialize()
    if status.is_error():
        raise RuntimeError('initialize: {}'.format(status.message()))

    nlp = PyomoNLP(model)
    res = app.optimize_tnlp(nlp)
    return res, nlp.solution


if __name__ == '__main__':
    print('Using pypopt version %s' % __version__)
    model = get_pyomo_model()

    res, solution = solve(model)

    print(res)
    print(solution)