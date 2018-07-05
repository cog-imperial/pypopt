Pypopt: Ipopt for Python
========================

Pypopt is an Ipopt wrapper for Python. The aim is to expose the same
API as Ipopt C++ interface.


Examples
--------

You can find examples in the ``examples/`` folder.


PythonJournal
-------------

In Pypopt you can use Python objects as targets for Ipopt journaling.
The Python objects needs to implement two methods:

* ``write(str)``: called to write ``str`` to the stream object
* ``flush()``: called to flush the stream

This means we can use Python3 ``io.StringIO`` to capture Ipopt output to string:

.. code-block:: python

    app = IpoptApplication()
    f = io.StringIO()
    j = PythonJournal(EJournalLevel.J_NONE, f)
    jnlst = app.journalist()
    jnlst.add_journal(j)


Requirements
------------

* A working C++ compiler
* Cython
* Ipopt
* Pytest + pytest-runner + pytest-cov for testing


Ipopt Installation
------------------

We recommend `installing Ipopt from source`__.

__ https://www.coin-or.org/Ipopt/documentation/node10.html

If you have Ipopt installed in a different location than ``/usr`` set
the following environment variables before proceeding to the next
section::

  IPOPT_INCLUDE_DIR=/path/to/ipopt/include
  IPOPT_LIBRARY_DIR=/path/to/ipopt/lib


Installation
------------

Pypopt is available on Pypi_::

  pip install pypopt

.. _Pypi: https://pypi.org/project/pypopt/


Installation from Source
------------------------

To install `pypopt` simply run::

  python setup.py install


Troubleshooting
---------------

Pypopt is a Cython extension, this makes it sometimes tricky to install correctly.


Different toolchain for Ipopt and Pypopt
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Ipopt and Pypopt need to be compiled with the same C++ toolchain. If
that's not the case, you will see an error like the following when
loading Pypopt::

  Traceback (most recent call last):
  File "<stdin>", line 1, in <module>
  File "/lib/python3.6/site-packages/pypopt/__init__.py", line 24, in <module>
    from pypopt._cython import (
  ImportError: /lib/python3.6/site-packages/pypopt/_cython.cpython-36m-x86_64-linux-gnu.so: undefined symbol: _ZN5Ipopt7Journal4NameB5cxx11Ev

This means Ipopt and Pypopt were compiled with different
compilers/flags.  To fix this issue install Ipopt from source and set
the ``IPOPT_INCLUDE_DIR`` and ``IPOPT_LIBRARY_DIR`` environment
variables to your Ipopt installation.


License
-------

Copyright 2018 Francesco Ceccon

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
