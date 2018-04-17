from libcpp cimport bool
from libcpp.string cimport string
from cython.operator cimport dereference as d
cimport pypopt.ipopt as ip


cdef class Journalist:
    cdef ip.SmartPtr[ip.Journalist] c_journalist

    def printf(self, level, category, fmt, *args, **kwargs):
        py_bytes = fmt.format(*args, **kwargs).encode('utf-8')
        cdef const char *c_str = py_bytes
        cdef ip.EJournalCategory c_category = category
        cdef ip.EJournalLevel c_level = level
        d(self.c_journalist).Printf(c_level, c_category, c_str)

    def print_string_over_lines(self, level, category, ip.Index indent_level,
                                ip.Index max_length, str line):
        cdef string c_line = line.encode('utf-8')
        cdef ip.EJournalCategory c_category = category
        cdef ip.EJournalLevel c_level = level
        d(self.c_journalist).PrintStringOverLines(
            c_level, c_category, indent_level, max_length, c_line,
        )

    def printf_indented(self, level, category, ip.Index indent_level, fmt, *args, **kwargs):
        py_bytes = fmt.format(*args, **kwargs).encode('utf-8')
        cdef const char *c_str = py_bytes
        cdef ip.EJournalCategory c_category = category
        cdef ip.EJournalLevel c_level = level
        d(self.c_journalist).PrintfIndented(c_level, c_category, indent_level, c_str)

    def can_produce_output(self, level, category):
        cdef ip.EJournalCategory c_category = category
        cdef ip.EJournalLevel c_level = level
        return d(self.c_journalist).ProduceOutput(c_level, c_category)

    def flush_buffer(self):
        d(self.c_journalist).FlushBuffer()

    def add_journal(self, Journal journal):
        cdef ip.SmartPtr[ip.Journal] c_journal = journal.c_journal
        return d(self.c_journalist).AddJournal(c_journal)

    def add_file_journal(self, str location_name, str fname, default_level=None):
        cdef ip.EJournalLevel c_level = ip.EJournalLevel.J_WARNING
        if default_level is not None:
            c_level = default_level
        cdef string c_location_name = location_name.encode('utf-8')
        cdef string c_fname = fname.encode('utf-8')
        c_journal = d(self.c_journalist).AddFileJournal(c_location_name, c_fname, c_level)
        if ip.IsNull(c_journal):
            return None
        journal = Journal()
        journal.c_journal = c_journal
        return journal

    def get_journal(self, str name):
        cdef string c_name = name.encode('utf-8')
        c_journal = d(self.c_journalist).GetJournal(c_name)
        if ip.IsNull(c_journal):
            return None
        journal = Journal()
        journal.c_journal = c_journal
        return journal

    def delete_all_journals(self):
        d(self.c_journalist).DeleteAllJournals()


cpdef enum EJournalLevel:
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


cpdef enum EJournalCategory:
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
