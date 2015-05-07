#!/bin/bash

# set -x

if [ ! -v tree ] ; then
  # you must set the location of the cMIPS root directory in the variable tree
  # tree=${HOME}/cMIPS
  # tree=${HOME}/cmips-code/cMIPS
  export tree="$(echo $PWD | sed -e 's:^\(/.*/cMIPS\)/.*:\1:')"
fi


# path to cross-compiler and binutils must be set to your installation
WORK_PATH=/home/soft/linux/mips/cross/bin
HOME_PATH=/opt/cross/bin

if [ -x /opt/cross/bin/mips-gcc ] ; then
    export PATH=$PATH:$HOME_PATH
elif [ -x /home/soft/linux/mips/cross/bin/mips-gcc ] ; then
    export PATH=$PATH:$WORK_PATH
else
    echo -e "\n\n\tPANIC: cross-compiler not installed\n\n" ; exit 1;
fi


usage()
{
cat << EOF
usage:	$0 [options] source.c
	creates {prog,data}.bin to be input by textbench

OPTIONS:
   -h    Show this message
   -O n  Optimization level, defaults to n=1 {0,1,2,3}
   -v    Verbose, creates memory map: source.map
   -W    GIve -Wall to GCC
   -mif  Generate output file ROM.mif for Altera's FPGAs
   -syn  Compile for synthesis, else for simulation
EOF
}

errorED()
{
cat <<EOF


	$pkg_vhd NEWER than header files;
	problem running edMemory.sh in $0


EOF
exit 1
}

if [ $# = 0 ] ; then usage ; exit 1 ; fi

miffile=false
synth=false
verbose=false
unset memory_map
level=1

while true ; do

    case "$1" in
        -h) usage ; exit 1
            ;;
        -O) level=$2
	    shift
            ;;
	-O0) level=0
	    ;;
	-O1) level=1
	    ;;
	-O2) level=2
	    ;;
	-O3) level=3
	    ;;
	-W | -Wall) warn=-Wall
	    ;;
        -v) verbose=true
            ;;
        -mif) miffile=true
            ;;
        -syn) synth=true
            ;;
        -x) set -x
            ;;
        *)  inp=${1%.c}
	    if [ ${inp}.c != $1 ] ; then
		usage ; echo "	invalid option: $1"; exit 1 ; fi
	    break
            ;;
    esac
    shift
done

if [ -z $inp ] ; then usage ; exit 1 ; fi


bin="${tree}"/bin
include="${tree}"/include
srcVHDL="${tree}"/vhdl

c_ld="${include}"/cMIPS.ld
c_h="${include}"/cMIPS.h
c_s="${include}"/cMIPS.s
c_io="${include}"/cMIPSio
c_start="${include}"/start
c_hndlrs="${include}"/handlers
c_stop="${include}"/stop

pkg_vhd="${srcVHDL}"/packageMemory.vhd

if [ $pkg_vhd -nt $c_h  -o\
     $pkg_vhd -nt $c_ld -o\
     $pkg_vhd -nt $c_s  ] ; then
    "${bin}"/edMemory.sh -v || errorED || exit 1
fi

src=${inp}.c
asm=${inp}.s
obj=${inp}.o
elf=${inp}.elf
bin=prog.bin
dat=data.bin

if [ $verbose = true ]; then  memory_map="-Map ${inp}.map" ; fi

if [ $synth = true ]; 
then S="-D FOR_SYNTHESIS" ; 
else S="-U FOR_SYNTHESIS" ; fi

(mips-gcc -O${level} $warn -DcMIPS -mno-gpopt -I"${include}" \
          -S ${src} $S -o ${asm}  ||  exit 1) && \
mips-gcc -O1 -DcMIPS -mno-gpopt -I"${include}" -S ${c_io}.c -o ${c_io}.s $S &&\
mips-as -O1 -EL -mips32 -I "${include}" -o ${obj} ${asm} && \
mips-as -O1 -EL -mips32 -I "${include}" -o ${c_start}.o ${c_start}.s && \
mips-as -O1 -EL -mips32 -I "${include}" -o ${c_hndlrs}.o ${c_hndlrs}.s && \
mips-as -O1 -EL -mips32 -I "${include}" -o ${c_stop}.o ${c_stop}.s && \
mips-as -O1 -EL -mips32 -I "${include}" -o ${c_io}.o ${c_io}.s && \
mips-ld -EL -e _start ${memory_map} -I "${include}" --script $c_ld \
    -o $elf ${c_start}.o ${c_hndlrs}.o ${c_io}.o $obj ${c_stop}.o || exit 1

mips-objcopy -S -j .text -O binary $elf $bin && \
  mips-objcopy -S -j .data -j .rodata -j .rodata1 -j .data1 \
     -j .sdata -j .lit8 -j .lit4 -j .sbss -j .bss \
     -O binary $elf $dat || exit 1

if [ $? == 0  -a  $verbose = true ]; then
  mips-objdump -z -D -EL -M reg-names=numeric --show-raw-insn \
      --section .text   --section .data \
      --section .rodata --section .sdata --section .sbss \
      --section .bss $elf
fi

if [ $? == 0  -a  $miffile = true ] ; then
   elf2mif.sh "$elf" || exit 1
fi


# --section .reginfo 

chmod a-x $bin $dat

