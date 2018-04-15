from libcpp cimport bool
from libcpp.string cimport string


cdef extern from "coin/IpOptionsList.hpp" namespace "Ipopt":
    cdef cppclass OptionsList:
        void clear()
        void PrintList(string&)
        void PrintUserOptions(string&)
        bool SetStringValue(const string&, const string&, bool, bool)
        bool SetNumericValue(const string&, Number, bool, bool)
        bool SetIntegerValue(const string&, Index, bool, bool)
        bool GetStringValue(const string&, string&, const string&)
