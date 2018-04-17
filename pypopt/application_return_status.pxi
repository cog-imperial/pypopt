cdef class ApplicationReturnStatus:
    cdef ip.ApplicationReturnStatus c_status

    def __cinit__(self, ip.ApplicationReturnStatus status):
        self.c_status = status

    def is_error(self):
        return self.c_status < 0

    def __str__(self):
        return 'ApplicationReturnStatus(status={})'.format(self.c_status)

    def __repr__(self):
        return '<{} at {}>'.format(str(self), hex(id(self)))
