from cython.operator cimport dereference as d
cimport ipopt as ip


cdef class IpoptApplication:
    cdef ip.SmartPtr[ip.IpoptApplication] c_app

    def __cinit__(self):
        self.c_app = ip.SmartPtr[ip.IpoptApplication](new ip.IpoptApplication())

    def initialize(self, allow_clobber=False, params_file=None):
        if params_file is not None:
            return ApplicationReturnStatus(
                d(self.c_app).Initialize(params_file, allow_clobber)
            )
        else:
            return ApplicationReturnStatus(
                d(self.c_app).Initialize(allow_clobber)
            )

    def print_copyright_message(self):
        d(self.c_app).PrintCopyrightMessage()

    def rethrow_non_ipopt_exceptions(self, dorethrow):
        return d(self.c_app).RethrowNonIpoptException(dorethrow)

    def optimize_tnlp(self, TNLP tnlp):
        cdef ip.SmartPtr[ip.TNLP] c_tnlp = new WrapperTNLP(tnlp)
        return ApplicationReturnStatus(
            d(self.c_app).OptimizeTNLP(c_tnlp)
        )

    def journalist(self):
        journalist = Journalist()
        c_journalist = d(self.c_app).Jnlst()
        if ip.IsNull(c_journalist):
            return
        journalist.c_journalist = c_journalist
        return journalist

    def options(self):
        options = OptionsList()
        c_options = d(self.c_app).Options()
        if ip.IsNull(c_options):
            return
        options.c_options = c_options
        return options

    def statistics(self):
        stats = SolveStatistics()
        c_stats = d(self.c_app).Statistics()
        if ip.IsNull(c_stats):
            return
        stats.c_statistics = c_stats
        return stats
