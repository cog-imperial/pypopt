from libcpp cimport bool
from pypopt.coin.alg_types cimport *
from pypopt.coin.typedef cimport *
from pypopt.coin.return_codes cimport *
from pypopt.coin.ipopt_data cimport *
from pypopt.coin.ipopt_calculated_quantities cimport *


cdef extern from "coin/IpTNLP.hpp" namespace "Ipopt":
    ctypedef enum IndexStyleEnum "Ipopt::TNLP::IndexStyleEnum":
        C_STYLE "Ipopt::TNLP::C_STYLE"
        FORTRAN_STYLE "Ipopt::TNLP::FORTRAN_STYLE"

    cdef cppclass TNLP:
        TNLP()
        void finalize_solution(SolverReturn, Index, const Number *, const Number *, const Number *,
                               Index, const Number *, const Number *, Number, const IpoptData *,
                               IpoptCalculatedQuantities *)

        bool intermediate_callback(AlgorithmMode, Index, Number, Number, Number, Number, Number,
                                   Number, Number, Number, Index, const IpoptData *,
                                   IpoptCalculatedQuantities *)
