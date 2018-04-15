from setuptools import setup
from setuptools.extension import Extension
from Cython.Build import cythonize

extensions = [Extension(
    'pypopt._cython',
    sources=[
        'pypopt/_cython.pyx',
    ],
    libraries=['ipopt'],
    language='c++',
    extra_compile_args=['-std=c++11'],
    extra_link_args=['-std=c++11'],
    include_dirs=['/Users/cek/miniconda3/envs/gopt/include'],
    library_dirs=['/Users/cek/miniconda3/envs/gopt/lib'],
)]


setup(
    name='pypopt',
    packages=['pypopt'],
    ext_modules=cythonize(extensions),
    setup_requires=['pytest-runner'],
    tests_require=['pytest', 'pytest-cov'],
)
