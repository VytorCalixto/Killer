#!/bin/bash

## ------------------------------------------------------------------------
## cMIPS, Roberto Hexsel, 30set2013, rev 08jan2015
## ------------------------------------------------------------------------

# set -x

errorED()
{
cat <<EOF


        $pkg_vhd NEWER than header files;
        problem running edMemory.sh in $0


EOF
exit 1
}

errorCOMPILING()
{
cat <<EOF


        $0: error in compiling VHDL sources


EOF
exit 1
}



if [ ! -v tree ] ; then
  # you must set the location of the cMIPS root directory in the variable tree
  # tree=${HOME}/cMIPS
  # tree=${HOME}/cmips-code/cMIPS
  export tree="$(echo $PWD | sed -e 's:^\(/.*/cMIPS\)/.*:\1:')"
fi


bin="${tree}"/bin
include="${tree}"/include
srcVHDL="${tree}"/vhdl
# obj="${tree}"/obj

c_ld="${include}"/cMIPS.ld
c_s="${include}"/cMIPS.s
c_h="${include}"/cMIPS.h

pkg_vhd="$srcVHDL/packageMemory.vhd"

if [ $pkg_vhd -nt $c_ld -o\
     $pkg_vhd -nt $c_s  -o\
     $pkg_vhd -nt $c_h  ] ; then
   "${bin}"/edMemory.sh -v || errorED || exit 1
fi

# cd "${obj}"

cd "${srcVHDL}"

simulator=tb_cmips

pkg="packageWires.vhd packageMemory.vhd packageExcp.vhd"

src="altera.vhd macnica.vhd aux.vhd memory.vhd cache.vhd instrcache.vhd ram.vhd rom.vhd units.vhd io.vhd uart.vhd pipestages.vhd exception.vhd core.vhd tb_cMIPS.vhd"

# build simulator
#ghdl --clean
#ghdl -a --ieee=standard "${srcVHDL}"/packageWires.vhd   || exit 1
#ghdl -a --ieee=standard "${srcVHDL}"/packageMemory.vhd  || exit 1
#ghdl -a --ieee=standard "${srcVHDL}"/packageExcp.vhd    || exit 1
#for F in ${src} ; do
#    if [ ! -s ${F}.o  -o  "${srcVHDL}"/${F}.vhd -nt ${F}.o ] ; then
#	ghdl -a --ieee=standard "${srcVHDL}"/${F}.vhd   || exit 1
#    fi
#done
#
#ghdl -c "${srcVHDL}"/*.vhd -e ${simulator}  || exit 1




# NOTE: when you add a new sourcefile to this project, you must include it
#       with "ghdl -i newFile.vhd" so that learns about it.  It may be
#       a good idea to remove ./.last_import fo force a full rebuild.
#       Of course, newFile.vhd must be added to the $src variable.

# if never imported sources, do it now
if [ ! -f .last_import ] ; then
   ghdl -i ${pkg}
   ghdl -i ${src}
   touch .last_import
fi

ghdl -m ${simulator} || errorCOMPILING

mv ${simulator} ..

cd ..

