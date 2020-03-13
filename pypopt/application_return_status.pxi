from coin.alg_types cimport SolverReturn as SR

cpdef enum SolverReturn:
    SUCCESS = SR.SUCCESS,
    MAXITER_EXCEEDED = SR.MAXITER_EXCEEDED,
    CPUTIME_EXCEEDED = SR.CPUTIME_EXCEEDED,
    STOP_AT_TINY_STEP = SR.STOP_AT_TINY_STEP,
    STOP_AT_ACCEPTABLE_POINT = SR.STOP_AT_ACCEPTABLE_POINT,
    LOCAL_INFEASIBILITY = SR.LOCAL_INFEASIBILITY,
    USER_REQUESTED_STOP = SR.USER_REQUESTED_STOP,
    FEASIBLE_POINT_FOUND = SR.FEASIBLE_POINT_FOUND,
    DIVERGING_ITERATES = SR.DIVERGING_ITERATES,
    RESTORATION_FAILURE= SR.RESTORATION_FAILURE,
    ERROR_IN_STEP_COMPUTATION = SR.ERROR_IN_STEP_COMPUTATION,
    INVALID_NUMBER_DETECTED= SR.INVALID_NUMBER_DETECTED,
    TOO_FEW_DEGREES_OF_FREEDOM = SR.TOO_FEW_DEGREES_OF_FREEDOM,
    INVALID_OPTION = SR.INVALID_OPTION,
    OUT_OF_MEMORY = SR.OUT_OF_MEMORY,
    INTERNAL_ERROR = SR.INTERNAL_ERROR,
    UNASSIGNED = SR.UNASSIGNED


cdef class ApplicationReturnStatus:
    cdef ip.ApplicationReturnStatus c_status

    def __cinit__(self, ip.ApplicationReturnStatus status):
        self.c_status = status

    def return_status(self):
        return self.c_status

    def as_int(self):
        return self.c_status

    def is_error(self):
        return self.c_status < 0

    def __str__(self):
        return 'ApplicationReturnStatus(status={})'.format(self.c_status)

    def __repr__(self):
        return '<{} at {}>'.format(str(self), hex(id(self)))
