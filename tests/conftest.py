import pytest
import pyomo.environ as pe
from pypopt import IpoptApplication


@pytest.fixture
def app():
    return IpoptApplication()


def model_with_n_variables(n):
    m = pe.ConcreteModel()
    m.I = range(n)
    m.x = pe.Var(m.I, bounds=(1, 5))
    # x[0]*x[2]*x[4]*...*x[n-2]*(x[1] + x[3] + ... + x[n-1])
    obj_expr = sum(m.x[2*i+1] for i in range(n//2))
    for i in range(n//2):
        obj_expr *= m.x[2*i]
    m.obj = pe.Objective(expr=obj_expr)
    c1_expr = 1.0
    for i in m.I:
        c1_expr *= m.x[i]
    m.c1 = pe.Constraint(expr=c1_expr >= 4*n)
    m.c2 = pe.Constraint(expr=sum(m.x[i]**2 for i in m.I) == 10*n)
    return m


@pytest.fixture
def small_model_hs071():
    m = pe.ConcreteModel()
    m.x = pe.Var(range(4), bounds=(1, 5))
    m.obj = pe.Objective(expr=m.x[0]*m.x[3]*(m.x[0] + m.x[1] + m.x[2]) + m.x[2])
    m.c1 = pe.Constraint(expr=m.x[0]*m.x[1]*m.x[2]*m.x[3] >= 25)
    m.c2 = pe.Constraint(expr=sum(m.x[i]**2 for i in range(4)) == 40)
    return m
