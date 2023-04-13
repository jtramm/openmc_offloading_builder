#!/bin/bash

# It is assumed that this script will be run in the top level of the OpenMC source directory (.../openmc/.)
# It will install OpenMC into the .../openmc/build/install directory

module load spack
module load cmake
module load cray-hdf5/1.12.2.1

export IGC_ForceOCLSIMDWidth=16
export OMP_TARGET_OFFLOAD=MANDATORY
unset LIBOMPTARGET_LEVEL_ZERO_COMMAND_BATCH
export LIBOMPTARGET_LEVEL_ZERO_USE_IMMEDIATE_COMMAND_LIST=1
export CFESingleSliceDispatchCCSMode=1 
export LIBOMPTARGET_DEVICES=SUBSUBDEVICE 

rm -rf build
mkdir build
cd build
icpx --version
cmake --preset=spirv_aot -Dsycl_sort=on -Ddevice_printf=off -Ddebug=off -DCMAKE_INSTALL_PREFIX=./install -Doptimize=on ..
make VERBOSE=1 install
