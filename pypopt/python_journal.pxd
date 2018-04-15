from libcpp.string cimport string
from libcpp cimport bool
cimport pypopt.ipopt as ip
from pypopt.coin.journalist cimport Journal


cdef extern from "python_journal.hpp":
    cdef cppclass PythonJournal(Journal):
        PythonJournal(ip.EJournalLevel, object)
