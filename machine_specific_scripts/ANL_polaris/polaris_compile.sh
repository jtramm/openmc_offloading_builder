#!/bin/bash
module use /home/jtramm/Modules/modulefiles
module load cmake
module load mpiwrappers/cray-mpich-llvm
module load cudatoolkit-standalone
export HDF5_ROOT=/home/jtramm/hdf5/hdf5_install

module load llvm/release-16.0.0

rm -rf build
mkdir build
cd build
cmake --preset=llvm_a100_mpi -DCMAKE_INSTALL_PREFIX=./install -Doptimize=on -Ddevice_printf=off -Ddebug=on -Dcuda_thrust_sort=on ..
make VERBOSE=1 install
