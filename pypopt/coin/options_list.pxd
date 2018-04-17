from libcpp cimport bool
from libcpp.string cimport string
from pypopt.coin.typedef cimport Index, Number


cdef extern from "coin/IpOptionsList.hpp" namespace "Ipopt":
    cdef cppclass OptionsList:
        void clear()
        void PrintList(string&)
        void PrintUserOptions(string&)

        bool SetStringValue(const string&, const string&, bool, bool)
        bool SetNumericValue(const string&, Number, bool, bool)
        bool SetIntegerValue(const string&, Index, bool, bool)

        bool SetStringValueIfUnset(const string&, const string&, bool, bool)
        bool SetNumericValueIfUnset(const string&, Number, bool, bool)
        bool SetIntegerValueIfUnset(const string&, Index, bool, bool)

        bool GetStringValue(const string&, string&, const string&)
        bool GetEnumValue(const string&, Index&, const string&)
        bool GetBoolValue(const string&, bool&, const string&)
        bool GetNumericValue(const string&, Number&, const string&)
        bool GetIntegerValue(const string&, Index&, const string&)
