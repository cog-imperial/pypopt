from libcpp cimport bool
from libcpp.string cimport string
from pypopt.coin.return_codes cimport *
from pypopt.coin.options_list cimport *
from pypopt.coin.smart_ptr cimport *
from pypopt.coin.journalist cimport *
from pypopt.coin.solve_statistics cimport *
from pypopt.coin.tnlp cimport *


cdef extern from "coin/IpIpoptApplication.hpp" namespace "Ipopt":
    cdef cppclass IpoptApplication:
        IpoptApplication() except +
        ApplicationReturnStatus Initialize(string, bool)
        ApplicationReturnStatus Initialize(bool)
        ApplicationReturnStatus OptimizeTNLP(const SmartPtr[TNLP]&)
        bool RethrowNonIpoptException(bool)
        void PrintCopyrightMessage()
        SmartPtr[OptionsList] Options()
        SmartPtr[Journalist] Jnlst()
        SmartPtr[SolveStatistics] Statistics()
