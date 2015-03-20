#!/bin/bash

# set -x

if [ ! -v tree ] ; then
  # you must set the location of the cMIPS root directory in the variable tree
  # tree=${HOME}/cMIPS
  # export tree="$(dirname "$(pwd)")"
  export tree="$(echo $PWD | sed -e 's:\(/.*/cMIPS\)/.*:\1:')"
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


usage() {
cat << EOF
usage:  $0 some_file_name.elf
        creates ROM.mif from an ELF object file some_file_name.elf

OPTIONS:
   -h    Show this message
EOF
}


if [ $# = 0 ] ; then usage ; exit 1 ; fi

inp=${1%.elf}

if [ ${inp}.elf != $1 ] ; then
   usage ; echo "  invalid input: $1"; exit 1
fi
   
elf=$1

mif=ROM.mif

mips-objdump -z -D -EL --section .text $elf |\
    sed -e '1,6d' -e '/^$/d' -e '/^ /!d' -e 's:\t: :g' -e 's#^ *\([a-f0-9]*\): *\(........\)  *\(.*\)$#\2;#' |\
    awk 'BEGIN{c=0;} //{ printf "%d : %s\n",c,$1 ; c=c+1; }' > xxxx

echo -e "\n-- cMIPS code\n\nDEPTH=4096;\nWIDTH=32;\n\n" > $mif
echo -e "ADDRESS_RADIX=DEC;\nDATA_RADIX=HEX;\nCONTENT BEGIN" >> $mif 
cat xxxx >> $mif
echo "END;" >> $mif

rm -f xxxx

exit 0
