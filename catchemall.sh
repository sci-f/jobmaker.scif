#!/bin/sh

max=10
for i in `seq 2 $max`
do
    /opt/conda/bin/pokemon --catch >> /dev/null
done
