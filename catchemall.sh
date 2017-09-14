#!/bin/sh

max=10
for i in `seq 2 $max`
do
    /usr/local/bin/pokemon --catch >> /dev/null
done
