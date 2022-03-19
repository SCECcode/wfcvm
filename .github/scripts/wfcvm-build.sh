#!/bin/bash

tmp=`uname -s`

if [ $tmp == 'Darwin' ]; then
##for macOS, make sure have automake/aclocal
  brew install automake
fi

aclocal
automake --add-missing
autoconf
cd data
cd ..
./configure --prefix=$UCVM_INSTALL_PATH/model/wfcvm
make
make install

