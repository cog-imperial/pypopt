from libcpp cimport bool
from libcpp.string cimport string

ctypedef double Number
ctypedef int Index


cdef extern from "coin/IpJournalist.hpp" namespace "Ipopt":
    cdef enum EJournalLevel:
        J_INSUPPRESSIBLE=-1,
        J_NONE=0,
        J_ERROR,
        J_STRONGWARNING,
        J_SUMMARY,
        J_WARNING,
        J_ITERSUMMARY,
        J_DETAILED,
        J_MOREDETAILED,
        J_VECTOR,
        J_MOREVECTOR,
        J_MATRIX,
        J_MOREMATRIX,
        J_ALL,
        J_LAST_LEVEL

    cdef enum EJournalCategory:
        J_DBG=0,
        J_STATISTICS,
        J_MAIN,
        J_INITIALIZATION,
        J_BARRIER_UPDATE,
        J_SOLVE_PD_SYSTEM,
        J_FRAC_TO_BOUND,
        J_LINEAR_ALGEBRA,
        J_LINE_SEARCH,
        J_HESSIAN_APPROXIMATION,
        J_SOLUTION,
        J_DOCUMENTATION,
        J_NLP,
        J_TIMING_STATISTICS,
        J_USER_APPLICATION  ,
        J_USER1  ,
        J_USER2  ,
        J_USER3  ,
        J_USER4  ,
        J_USER5  ,
        J_USER6  ,
        J_USER7  ,
        J_USER8  ,
        J_USER9  ,
        J_USER10  ,
        J_USER11  ,
        J_USER12  ,
        J_USER13  ,
        J_USER14  ,
        J_USER15  ,
        J_USER16  ,
        J_USER17  ,
        J_LAST_CATEGORY
