#!/bin/bash

## ------------------------------------------------------------------------
## classicalMIPS, Roberto Hexsel, 23nov2012
## ------------------------------------------------------------------------

# set -x


if [ ! -v tree ] ; then
  # you must set the location of the cMIPS root directory in the variable tree
  # tree=${HOME}/cMIPS
  # tree=${HOME}/cmips-code/cMIPS
  export tree="$(echo $PWD | sed -e 's:\(/.*/cMIPS\)/.*:\1:')"
fi

bin=${tree}/bin
include=${tree}/include
srcVHDL=${tree}/vhdl

simulator="${tree}"/tb_cmips

visual="${tree}"/v_cMIPS.vcd
unset WAVE

length=1
unit=m
gtkwconf=v

touch input.data input.txt serial.inp

usage() {
cat << EOF
usage:  $0 [options] 
        re-create simulator/model and run simulation
        prog.bin and data.bin must be in the current directory

OPTIONS:
   -h    Show this message
   -t T  number of time-units to run (default ${length})
   -u U  unit of time scale {m,u,n,p} (default ${unit}s)
   -n    send simulator output do /dev/null, else to v_cMIPS.vcd
   -w    invoke GTKWAVE
   -v F  gtkwave configuration file (e.g. pipe.sav, default v.sav)
EOF
}

while true ; do

    case "$1" in
        -h | "-?") usage ; exit 1
            ;;
        -t) length=$2
            shift
            ;;
        -u) unit=$2
            shift
            ;;
	-n) visual=/dev/null
	    ;;
	-w) WAVE=true
	    ;;
        -v) gtkwconf=$2
            shift
            ;;
	-x) set -x
	    ;;
	"") break
	    ;;
	*) usage ; echo "  invalid option: $1"; exit 1
	    ;;
    esac
    shift
done

gfile=${gtkwconf%%.sav}

sav="${tree}"/${gfile}.sav

"${bin}"/build.sh &&\
"${simulator}" --ieee-asserts=disable --stop-time=${length}${unit}s \
               --vcd=${visual}
# --wave=${visual%.vcd}.ghw

test -v $WAVE  ||  gtkwave -O /dev/null ${visual} ${sav}

