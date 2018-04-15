from libcpp cimport bool


cdef extern from "coin/IpSmartPtr.hpp" namespace "Ipopt":
    cdef cppclass SmartPtr[T]:
        SmartPtr()
        SmartPtr(T*)
        T& operator*()
        SmartPtr[T]& operator=(T*)

    bool IsNull[U](const SmartPtr[U]&)
