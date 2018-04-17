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
