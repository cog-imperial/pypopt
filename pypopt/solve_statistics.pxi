cimport ipopt as ip


cdef class SolveStatistics:
    cdef ip.SmartPtr[ip.SolveStatistics] c_statistics
