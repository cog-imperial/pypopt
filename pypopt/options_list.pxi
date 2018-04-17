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
