from libcpp.string cimport string
from pypopt.python_journal cimport PythonJournal as CppPythonJournal
cimport pypopt.ipopt as ip


cdef class PythonJournal:
    cdef CppPythonJournal *c_journal

    def __cinit__(self, level, out_stream):
        cdef ip.EJournalLevel c_level = level
        self.c_journal = new CppPythonJournal(c_level, out_stream)

    def __dealloc__(self):
        del self.c_journal

    def name(self):
        cdef string c_name = self.c_journal.Name()
        return c_name

    def set_print_level(self, category, level):
        cdef ip.EJournalCategory c_category = category
        cdef ip.EJournalLevel c_level = level
        self.c_journal.SetPrintLevel(c_category, c_level)

    def set_all_print_levels(self, level):
        cdef ip.EJournalLevel c_level = level
        self.c_journal.SetAllPrintLevels(c_level)

    def is_accepted(self, category, level):
        cdef ip.EJournalCategory c_category = category
        cdef ip.EJournalLevel c_level = level
        return self.c_journal.IsAccepted(c_category, c_level)

    def print_(self, category, level, bytes str_):
        cdef ip.EJournalCategory c_category = category
        cdef ip.EJournalLevel c_level = level
        cdef const char *c_str = str_
        self.c_journal.Print(c_category, c_level, c_str)

    def flush_buffer(self):
        self.c_journal.FlushBuffer()
