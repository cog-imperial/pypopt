# Copyright 2018 Francesco Ceccon
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# pylint: skip-file
import os
from setuptools import setup, find_packages
from setuptools.extension import Extension
from Cython.Build import cythonize
from pathlib import Path

project_root = Path(__file__).resolve().parent

about = {}
version_path = project_root / 'pypopt' / '__version__.py'
with version_path.open() as f:
    exec(f.read(), about)

with (project_root / 'README.rst').open() as f:
    readme = f.read()

with (project_root / 'CHANGELOG.rst').open() as f:
    changelog = f.read()

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
    description=about['__description__'],
    version=about['__version__'],
    author=about['__author__'],
    author_email=about['__author_email__'],
    license=about['__license__'],
    long_description=readme + '\n\n' + changelog,
    packages=find_packages(exclude=['tests']),
    ext_modules=cythonize(extensions),
    include_package_data=True,
    setup_requires=['pytest-runner', 'cython'],
    tests_require=['pytest', 'pytest-cov'],
    classifiers=[
        'Development Status :: 4 - Beta',
        'Intended Audience :: Science/Research',
        'Programming Language :: Python :: 3.5',
        'Programming Language :: Python :: 3.6',
        'Topic :: Scientific/Engineering :: Mathematics',
    ],
)
