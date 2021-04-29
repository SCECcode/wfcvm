WFCVM README

1) Installation

$ aclocal
$ autoconf
$ automake
$ ./configure --prefix=/dir/to/install
$ make
$ make install

2) Programs

a) ASCII query interface XXX_txt

   Accepts points from stdin with format (lat, lon, dep (m)) and 
writes data material properties to std out with format (lat, lon, dep, 
vp, vs, density).

a) Binary query interface XXX_bin

   Reads a configuration file named 'cvm-input' with the following 
items:

line 1: number of points
line 2: path to input lon file
line 3: path to input lat file
line 4: path to input dep file
line 5: path to output rho file
line 6: path to output vp file
line 7: path to output vs file

   The input and output files are in binary (float) format, with each
containing the number of points specified on line 1. 


3) API Library

The library ./lib/libwfcvm.a may be statically linked into any
user application. The header file defining the API is located
in ./include/wfcvm.h.

