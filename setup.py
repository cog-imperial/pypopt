import os
from setuptools import setup, find_packages
from setuptools.extension import Extension
from Cython.Build import cythonize

include_dirs = []
if os.environ.get('IPOPT_INCLUDE_DIR'):
    include_dirs.append(os.environ.get('IPOPT_INCLUDE_DIR'))

library_dirs = []
if os.environ.get('IPOPT_LIBRARY_DIR'):
    library_dirs.append(os.environ.get('IPOPT_LIBRARY_DIR'))


extensions = [Extension(
    'pypopt._cython',
    sources=[
        'pypopt/_cython.pyx',
    ],
    libraries=['ipopt'],
    language='c++',
    extra_compile_args=['-std=c++11'],
    extra_link_args=['-std=c++11'],
    include_dirs=include_dirs,
    library_dirs=library_dirs,
)]


setup(
    name='pypopt',
    packages=find_packages(exclude=['tests']),
    ext_modules=cythonize(extensions),
    setup_requires=['pytest-runner', 'cython'],
    tests_require=['pytest', 'pytest-cov'],
)
