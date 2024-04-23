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
#module load llvm/release-11.0.1

# We also need CMake
module load cmake
module load spack
#module load ninja
module load rocm/6.0.0

# These are the options we will set for this build
PROJECTS="clang;lld"
RUNTIMES="openmp"
TARGETS="all"
USE_CCACHE=OFF

# This script will make two folders in the current directly: llvm-build, llvm-install
rm -rf llvm-build
mkdir llvm-build

rm -rf llvm-install
mkdir llvm-install

cd llvm-build

#cmake -G "Ninja" \
cmake \
    -DCMAKE_C_COMPILER=gcc \
    -DCMAKE_CXX_COMPILER=g++ \
    -DLLVM_ENABLE_PROJECTS=${PROJECTS}  \
    -DLLVM_ENABLE_RUNTIMES=${RUNTIMES}   \
    -DLLVM_TARGETS_TO_BUILD=${TARGETS}   \
    -DLLVM_ENABLE_ASSERTIONS=ON \
    -DLIBOMPTARGET_ENABLE_DEBUG=ON \
    -DLLVM_OPTIMIZED_TABLEGEN=ON \
    -DBUILD_SHARED_LIBS=ON \
    -DLLVM_CCACHE_BUILD=${USE_CCACHE} \
    -DLLVM_APPEND_VC_REV=OFF \
    -DCMAKE_BUILD_TYPE=RelWithDebInfo \
    -DCMAKE_EXPORT_COMPILE_COMMANDS=ON \
    -DCMAKE_CXX_FLAGS="-Wno-address" \
    -DCMAKE_INSTALL_PREFIX=../llvm-install \
    ../llvm-project/llvm

#ninja -j32
#ninja install
make -j32 install

# Once installed, you'll need to update your environment as:

# export PATH=/path/to/llvm-install/bin:$PATH
# export LD_LIBRARY_PATH=/path/to/llvm-install/lib:$LD_LIBRARY_PATH
# export LIBRARY_PATH=/path/to/llvm-install/lib:$LIBRARY_PATH

# When running the compiler on NVIDIA, you'll also need to load CUDA:

# module load cuda

# When running the compiler on AMD, you'll also need to load ROCM, e.g.:

# module load rocm/6.0.0

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
# module load rocm/6.0.0
