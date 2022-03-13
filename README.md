# WFCVM(wfcvm)

Wasatch Front Community Velocity Model. Currently,the model includes Cache, 
Weber/Davis, Salt Lake, and Utah basin.

## Installation

This package is intended to be installed as part of the UCVM framework,
version 19.4.0 or higher. 

This package can also be installed standalone

$ aclocal
$ autoconf
$ automake
$ ./configure --prefix=$UCVM_INSTALL_PATH/model/wfcvm
$ make
$ make install

### ASCII query interface wfcvm_txt

Accepts points from stdin with format (lat, lon, dep (m)) and 
writes data material properties to std out with format (lat, lon, dep, 
vp, vs, density).

### Binary query interface wfcm_bin ???

Reae s a configuration file named 'cvm-input' with the following 
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


## Contact the authors

If you would like to contact the authors regarding this software,
please e-mail software@scec.org. Note this e-mail address should
be used for questions regarding the software itself (e.g. how
do I link the library properly?). Questions regarding the model's
science (e.g. on what paper is the WFCVM based?) should be directed
to the model's authors, located in the AUTHORS file.
WFCVM README
