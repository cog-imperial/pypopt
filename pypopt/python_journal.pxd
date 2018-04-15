from libcpp.string cimport string
from libcpp cimport bool
cimport pypopt.ipopt as ip


cdef extern from "python_journal.hpp":
    cdef cppclass PythonJournal:
        PythonJournal(ip.EJournalLevel, object)
        string Name()
        void SetPrintLevel(ip.EJournalCategory, ip.EJournalLevel)
        void SetAllPrintLevels(ip.EJournalLevel)
        bool IsAccepted(ip.EJournalCategory, ip.EJournalLevel)
        void Print(ip.EJournalCategory, ip.EJournalLevel, const char *)
        void FlushBuffer()
