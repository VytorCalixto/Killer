#!/bin/bash

# set -x

if [ ! -v tree ] ; then
  # you must set the location of the cMIPS root directory in the variable tree
  # tree=${HOME}/cmips-code/cMIPS
  export tree="$(echo $PWD | sed -e 's:^\(/.*/cMIPS\)/.*:\1:')"
fi

srcVHDL=${tree}/vhdl

pack=$srcVHDL/packageWires.vhd

# for ROM in 0 1 2 3 5 10 13 14; do 

for ROM in 0 1 ; do 
  sed -i -e "/ROM_WAIT_STATES/s/ := \([0-9][0-9]*\);/ := ${ROM};/" $pack
  echo -n "rom=$ROM"
  # for RAM in 0 1 15 11 10 5 4 3 2; do 
  for RAM in 0 1 ; do 
      sed -i -e "/RAM_WAIT_STATES/s/ := \([0-9][0-9]*\);/ := ${RAM};/" $pack
      echo " ram=$RAM"
      ./doTests.sh || exit 1
  done
done

sed -i -e "/ROM_WAIT_STATES/s/ := \([0-9][0-9]*\);/ := 0;/" \
       -e "/RAM_WAIT_STATES/s/ := \([0-9][0-9]*\);/ := 0;/" $pack

