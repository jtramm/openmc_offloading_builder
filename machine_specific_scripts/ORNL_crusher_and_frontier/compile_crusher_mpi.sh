#!/bin/bash
module use /gpfs/alpine/csc404/proj-shared/openmc/Modules/modulefiles
module load llvm/current

rm -rf build
mkdir build
cd build
cmake --preset=llvm_mi250x_mpi -DCMAKE_INSTALL_PREFIX=./install -Doptimize=on -Ddevice_printf=off -Ddebug=on -Dhip_thrust_sort=on ..
make VERBOSE=1 install
