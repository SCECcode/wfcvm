# The Wasatch Front Community Velocity Model (WFCVM)

<a href="https://github.com/sceccode/wfcvm.git"><img src="https://github.com/sceccode/wfcvm/wiki/images/wfcvm_logo.png"></a>

[![License](https://img.shields.io/badge/License-BSD_3--Clause-blue.svg)](https://opensource.org/licenses/BSD-3-Clause)
![GitHub repo size](https://img.shields.io/github/repo-size/sceccode/wfcvm)
[![wfcvm-ci Actions Status](https://github.com/SCECcode/wfcvm/workflows/wfcvm-ci/badge.svg)](https://github.com/SCECcode/wfcvm/actions)
[![wfcvm-wfcvm-ci Actions Status](https://github.com/SCECcode/wfcvm/workflows/wfcvm-wfcvm-ci/badge.svg)](https://github.com/SCECcode/wfcvm/actions)

## Description

Wasatch Front Community Velocity Model. Currently,the model includes Cache, 
Weber/Davis, Salt Lake, and Utah basin.

## Table of Content
1. [Software Documentation](https://github.com/SCECcode/wfcvm/wiki)
2. [Installation](#installation)
3. [Usage](#usage)
4. [License](#license)

## Installation

This package is intended to be installed as part of the UCVM framework,
version 19.4.0 or higher. 

This package can also be installed standalone

<pre>
$ aclocal
$ autoconf
$ automake
$ ./configure --prefix=/path/to/install
$ make
$ make install
</pre>

## Usage

### UCVM

As part of UCVM(https://github.com/SCECcode/ucvm) installation, use 'wfcvm' as the model.

### wfcvm_txt

ASCII query interface accepts points from stdin with format (lat, lon, dep (m)) and 
writes data material properties to std out with format (lat, lon, dep, 
vp, vs, density).

#### wfcm_bin

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

## License
This software is distributed under the BSD 3-Clause open-source license.
Please see the [LICENSE.txt](LICENSE.txt) file for more information.
