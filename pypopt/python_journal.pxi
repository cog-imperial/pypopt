from libcpp.string cimport string
from cython.operator cimport dereference as d
cimport pypopt.ipopt as ip
from pypopt.python_journal cimport PythonJournal as CppPythonJournal


cdef class Journal:
    cdef ip.SmartPtr[ip.Journal] c_journal

    def name(self):
        cdef string c_name = d(self.c_journal).Name()
        return c_name

    def set_print_level(self, category, level):
        cdef ip.EJournalCategory c_category = category
        cdef ip.EJournalLevel c_level = level
        d(self.c_journal).SetPrintLevel(c_category, c_level)

    def set_all_print_levels(self, level):
        cdef ip.EJournalLevel c_level = level
        d(self.c_journal).SetAllPrintLevels(c_level)

    def is_accepted(self, category, level):
        cdef ip.EJournalCategory c_category = category
        cdef ip.EJournalLevel c_level = level
        return d(self.c_journal).IsAccepted(c_category, c_level)

    def print_(self, category, level, bytes str_):
        cdef ip.EJournalCategory c_category = category
        cdef ip.EJournalLevel c_level = level
        cdef const char *c_str = str_
        d(self.c_journal).Print(c_category, c_level, c_str)

    def flush_buffer(self):
        d(self.c_journal).FlushBuffer()


cdef class PythonJournal(Journal):
    def __cinit__(self, level, out_stream):
        cdef ip.EJournalLevel c_level = level
        self.c_journal = ip.SmartPtr[ip.Journal](new CppPythonJournal(c_level, out_stream))
