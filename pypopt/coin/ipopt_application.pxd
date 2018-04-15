from libcpp cimport bool
from libcpp.string cimport string
from pypopt.coin.return_codes cimport *
from pypopt.coin.options_list cimport *
from pypopt.coin.smart_ptr cimport *


cdef extern from "coin/IpIpoptApplication.hpp" namespace "Ipopt":
    cdef cppclass IpoptApplication:
        IpoptApplication() except +
        ApplicationReturnStatus Initialize(string, bool)
        ApplicationReturnStatus Initialize(bool)
        # ApplicationReturnStatus OptimizeTNLP(const SmartPtr[TNLP]&)
        bool RethrowNonIpoptException(bool)
        void PrintCopyrightMessage()
        SmartPtr[OptionsList] Options()
        # SmartPtr[SolveStatistics] Statistics()
