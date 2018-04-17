from cython.operator cimport dereference as d
from libcpp.string cimport string
cimport ipopt as ip


cdef class OptionsList:
    cdef ip.SmartPtr[ip.OptionsList] c_options

    def clear(self):
        return d(self.c_options).clear()

    def get_list(self):
        cdef string c_outlist
        d(self.c_options).PrintList(c_outlist)
        # convert to python str
        outlist = c_outlist.decode('utf-8')
        lines = outlist.split('\n')
        opts = []
        # skip first (header) and last (empty)
        for line in lines[1:-1]:
            o = line.split()
            opts.append({
                'name': o[0],
                'value': o[2],
                'times_used': o[3],
            })
        return opts

    def set_string_value(self, str tag, str value, allow_clobber=True, dont_print=False):
        cdef string c_tag = tag.encode('utf-8')
        cdef string c_value = value.encode('utf-8')
        return d(self.c_options).SetStringValue(c_tag, c_value, allow_clobber, dont_print)

    def set_numeric_value(self, str tag, ip.Number value, allow_clobber=True, dont_print=False):
        cdef string c_tag = tag.encode('utf-8')
        return d(self.c_options).SetNumericValue(c_tag, value, allow_clobber, dont_print)

    def set_integer_value(self, str tag, ip.Index value, allow_clobber=True, dont_print=False):
        cdef string c_tag = tag.encode('utf-8')
        return d(self.c_options).SetIntegerValue(c_tag, value, allow_clobber, dont_print)

    def set_string_value_if_unset(self, str tag, str value, allow_clobber=True, dont_print=False):
        cdef string c_tag = tag.encode('utf-8')
        cdef string c_value = value.encode('utf-8')
        return d(self.c_options).SetStringValueIfUnset(c_tag, c_value, allow_clobber, dont_print)

    def set_numeric_value_if_unset(self, str tag, ip.Number value, allow_clobber=True, dont_print=False):
        cdef string c_tag = tag.encode('utf-8')
        return d(self.c_options).SetNumericValueIfUnset(c_tag, value, allow_clobber, dont_print)

    def set_integer_value_if_unset(self, str tag, ip.Index value, allow_clobber=True, dont_print=False):
        cdef string c_tag = tag.encode('utf-8')
        return d(self.c_options).SetIntegerValueIfUnset(c_tag, value, allow_clobber, dont_print)

    def get_string_value(self, str tag, str prefix=''):
        cdef string c_tag = tag.encode('utf-8')
        cdef string c_prefix = tag.encode('utf-8')
        cdef string c_value
        found = d(self.c_options).GetStringValue(c_tag, c_value, c_prefix)
        if not found:
            return
        return c_value.decode('utf-8')

    def get_enum_value(self, str tag, str prefix=''):
        cdef string c_tag = tag.encode('utf-8')
        cdef string c_prefix = tag.encode('utf-8')
        cdef ip.Index c_value = -1
        found = d(self.c_options).GetEnumValue(c_tag, c_value, c_prefix)
        if not found:
            return
        return c_value

    def get_bool_value(self, str tag, str prefix=''):
        cdef string c_tag = tag.encode('utf-8')
        cdef string c_prefix = tag.encode('utf-8')
        cdef bool c_value = False
        found = d(self.c_options).GetBoolValue(c_tag, c_value, c_prefix)
        if not found:
            return
        return c_value

    def get_numeric_value(self, str tag, str prefix=''):
        cdef string c_tag = tag.encode('utf-8')
        cdef string c_prefix = tag.encode('utf-8')
        cdef ip.Number c_value = -1
        found = d(self.c_options).GetNumericValue(c_tag, c_value, c_prefix)
        if not found:
            return
        return c_value

    def get_integer_value(self, str tag, str prefix=''):
        cdef string c_tag = tag.encode('utf-8')
        cdef string c_prefix = tag.encode('utf-8')
        cdef ip.Index c_value = -1
        found = d(self.c_options).GetIntegerValue(c_tag, c_value, c_prefix)
        if not found:
            return
        return c_value
