#pragma once

#include <coin/IpJournalist.hpp>
#include <Python.h>


class PythonJournal : public Ipopt::Journal {
public:
  PythonJournal(Ipopt::EJournalLevel default_level, PyObject *stream)
    : Journal("PythonJournal", default_level)
    , stream_(stream) {
    Py_XINCREF(stream_);
  }

  virtual ~PythonJournal() {
    Py_XDECREF(stream_);
  }

protected:
  virtual void PrintImpl(Ipopt::EJournalCategory category,
			 Ipopt::EJournalLevel level,
			 const char* str) override {
    PyObject_CallMethod(stream_, "write", "s", str);
  }

  virtual void PrintfImpl(Ipopt::EJournalCategory category,
			  Ipopt::EJournalLevel level,
			  const char* pformat,
			  va_list ap) override {
    // Define string
    static const int max_len = 8192;
    char s[max_len];

    if (vsnprintf(s, max_len, pformat, ap) > max_len) {
      PrintImpl(category, level, "Warning: not all characters of next line are printed to the file.\n");
    }
    PrintImpl(category, level, s);
  }

  virtual void FlushBufferImpl() override {
    PyObject_CallMethod(stream_, "flush", "");
  }

private:
  PyObject *stream_;
};
