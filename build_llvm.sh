#!/bin/bash
set -xe

# This script compiles LLVM to enable offloading to both AMD and NVIDIA devices

# First, you'll want to clone the current working version of LLVM
# git clone https://github.com/llvm/llvm-project

# This script is configured to assume you will run it in the same directoy that contains 
# the llvm-project directory (i.e., not inside the llvm-project directory itself)

# In this script, we are using an older (non-offloading) version of LLVM to compile.
# There is nothing special about this version of LLVM, it's just the one we have available
# on my cluster.
# If you want to use gcc or something else, you'll need to also edit the cmake line to point
# to your descired c and c++ compilers
module load llvm/release-11.0.1

# We also need CMake
module load spack
module load cmake

# These are the options we will set for this build
PACKAGES="clang;compiler-rt;lld"
RUNTIMES="libcxxabi;libcxx;openmp"

# This script will make two folders in the current directly: llvm-build
rm -rf llvm-build
mkdir llvm-build
cd llvm-build

# Edit the DCMAKE_INSTALL_PREFIX part of the line below to point to where you want it to install
cmake -DCMAKE_C_COMPILER=clang -DCMAKE_CXX_COMPILER=clang++ \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_INSTALL_PREFIX=/gpfs/jlse-fs0/users/jtramm/compilers/llvm-install \
    -DLLVM_ENABLE_BACKTRACES=ON \
    -DLLVM_ENABLE_WERROR=OFF \
    -DBUILD_SHARED_LIBS=OFF \
    -DLLVM_ENABLE_RTTI=ON \
    -DLLVM_ENABLE_ASSERTIONS=ON \
    -DLLVM_ENABLE_PROJECTS="$PACKAGES" \
    -DLLVM_ENABLE_RUNTIMES="$RUNTIMES" \
    -DOPENMP_ENABLE_LIBOMPTARGET=ON \
    -DLIBOMPTARGET_NVPTX_COMPUTE_CAPABILITIES=35,60,70,75,80 \
    -DCLANG_OPENMP_NVPTX_DEFAULT_ARCH=sm_80 \
    -DLIBOMPTARGET_NVPTX_ENABLE_BCLIB=ON \
    -DLIBOMPTARGET_ENABLE_DEBUG=ON \
    ../llvm-project/llvm

make -j32 install

# Once installed, you'll need to update your environment as:

# export PATH=/path/to/llvm-install/bin:$PATH
# export LD_LIBRARY_PATH=/path/to/llvm-install/lib:$LD_LIBRARY_PATH
# export LIBRARY_PATH=/path/to/llvm-install/lib:$LIBRARY_PATH

# When running the compiler on NVIDIA, you'll also need to load CUDA:

# module load cuda


# Example of a module file you might create to make the installation easier:

#%Module

# proc ModulesHelp { } {
#    puts stderr "This module adds LLVM with OpenMP Offloading to your path"
# }
# 
# module-whatis "This module adds LLVM with OpenMP Offloading to your path\n"
# 
# set basedir "/path/to/llvm-install"
# prepend-path PATH "${basedir}/bin"
# prepend-path LD_LIBRARY_PATH "${basedir}/lib"
# prepend-path LIBRARY_PATH "${basedir}/lib"
# module load cuda
