#!/bin/bash

IN_FILE=$1
OUT_FILE=$2
MODEL_PATH=`pwd`/../data/3d

./wfcvm_txt ${MODEL_PATH} < ${IN_FILE} > ${OUT_FILE}

if [ $? -ne 0 ]; then
    exit 1
fi

exit 0
