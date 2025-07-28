# Wasatch Front Community Velocity Model (WFCVM)

<a href="https://github.com/sceccode/wfcvm.git"><img src="https://github.com/sceccode/wfcvm/wiki/images/wfcvm_logo.png"></a>

[![License](https://img.shields.io/badge/License-BSD_3--Clause-blue.svg)](https://opensource.org/licenses/BSD-3-Clause)
![GitHub repo size](https://img.shields.io/github/repo-size/sceccode/wfcvm)
[![wfcvm-ucvm-ci Actions Status](https://github.com/SCECcode/wfcvm/workflows/wfcvm-ucvm-ci/badge.svg)](https://github.com/SCECcode/wfcvm/actions)

Wasatch Front Community Velocity Model

This model includes Cache, Weber/Davis, Salt Lake, and Utah basins.

The Wasatch Front CVM consists of detailed, rule-based representations of the major populated sediment-filled basins, embedded in a 3D crust, over a variable depth Moho, over upper mantle velocities. The basins are parameterized as a set of objects and rules implemented in a computer code that generates seismic velocities and density at any desired point. The objects are stratigraphic surfaces constructed from geological, geophysical, and geotechnical data, and the rule is Faust’s relation Vp = k(da)1/6 where Vp is P-wave velocity, d is the maximum depth of burial of the sediments, a is the sediment age, and k is a constant. Age at any point in a basin can be interpolated from the surfaces. The constant k is calibrated for each surface by comparison to well sonic logs and seismic refraction surveys. Density is derived from Vp using a standard relation; density is used to find Poisson's ratio and Vs is calculated from the Vp and Poisson's ratio. The shallow basin velocities are directly constrained by geotechnical borehole logs and detailed surface site response unit mapping based on surface geology and Vs30 measurements.

Magistrale, H, Olsen, KB, Pechmann, JC (2008) Construction and verification of a Wasatch front community velocity model. Technical report no. HQGR.060012, 14 pp. Reston, VA: US Geological Survey

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
