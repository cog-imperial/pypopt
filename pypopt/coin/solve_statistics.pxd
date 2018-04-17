from libcpp cimport bool
from libcpp.string cimport string
from pypopt.coin.typedef cimport Index, Number


cdef extern from "coin/IpSolveStatistics.hpp" namespace "Ipopt":
    cdef cppclass SolveStatistics:
        Index IterationCount();
