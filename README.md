# Wasatch Front Community Velocity Model (WFCVM)

<a href="https://github.com/sceccode/wfcvm.git"><img src="https://github.com/sceccode/wfcvm/wiki/images/wfcvm_logo.png"></a>

[![License](https://img.shields.io/badge/License-BSD_3--Clause-blue.svg)](https://opensource.org/licenses/BSD-3-Clause)
![GitHub repo size](https://img.shields.io/github/repo-size/sceccode/wfcvm)
[![wfcvm-ucvm-ci Actions Status](https://github.com/SCECcode/wfcvm/workflows/wfcvm-ucvm-ci/badge.svg)](https://github.com/SCECcode/wfcvm/actions)

Wasatch Front Community Velocity Model

This model includes Cache, Weber/Davis, Salt Lake, and Utah basins.

## Installation

This package is intended to be installed as part of the UCVM framework,
version 25.7 or higher. 

## Library

The library ./lib/libwfcvm.a may be statically linked into any
user application. Also, if your system supports dynamic linking,
you will also have a ./lib/libwfcvm.so file that can be used
for dynamic linking. The header file defining the API is located
in ./include/wfcvm.h.

## Contact the authors

If you would like to contact the authors regarding this software,
please e-mail software@scec.org. Note this e-mail address should
be used for questions regarding the software itself (e.g. how
do I link the library properly?). Questions regarding the model's
science (e.g. on what paper is the WFCVM based?) should be directed
to the model's authors, located in the AUTHORS file.

## To build in standalone mode

To install this package on your computer, please run the following commands:

<pre>
  aclocal
  autoconf
  automake
  ./configure --prefix=/path/to/install
  make
  make install
</pre>

### wfcvm_txt

ASCII query interface accepts points from stdin with format (lat, lon, dep (m)) and 
writes data material properties to std out with format (lat, lon, dep, 
vp, vs, density).

### wfcm_bin

Binary query interface reads a configuration file named 'cvm-input' with the following 
items:

<pre>
line 1: number of points
line 2: path to input lon file
line 3: path to input lat file
line 4: path to input dep file
line 5: path to output rho file
line 6: path to output vp file
line 7: path to output vs file
</pre>

The input and output files are in binary (float) format, with each
containing the number of points specified on line 1. 
