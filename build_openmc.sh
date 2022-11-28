#!/bin/bash  

####################################################################
# Command line options:
# all - Does all basic steps (download + compile + validate)
# download - only downloads data files
# compile - only compiles (deletes old build and install first)
# validate - runs a small test problem and checks for correctness
# performance - runs a large test problem and reports performance
#
# e.g., "./build_openmc.sh all" or "./build_openmc.sh performance"
####################################################################

# Check for command line arguments
if [ $# -eq 0 ]; then
 echo "Command line options:
 all - Does all basic steps (download + compile + validate)
 download - only downloads data files
 compile - only compiles (deletes old build and install first)
 validate - runs a small test problem and checks for correctness
 performance - runs a large test problem and reports performance
 e.g., \"./build_openmc.sh all\" or \"./build_openmc.sh performance\""
 exit 1
fi

####################################################################
# START PREAMBLE
# NOTE - You may need to edit this section to point to or load
# your specific dependencies (HDF5, CMake, and an OpenMP compiler)
# and to select which offloading target you want.
####################################################################

# HDF5 and CMake dependencies
module load spack
module load cmake
module load hdf5 # If you have manually compiled HDF5, set HDF5_ROOT

# Compiler dependency (llvm, oneapi)
module load llvm/sep1_patched

# Target selection (full list in OpenMC's main directory
# CmakePrests.json file at:
# https://github.com/exasmr/openmc/blob/openmp-target-offload/CMakePresets.json)
# (some options are llvm_a100, llvm_v100, llvm_mi100, llvm_mi250x, spirv_aot)
OPENMC_TARGET=llvm_a100

# If you are compiling for NVIDIA or Intel, you may want to enable
# use of a vendor library to accelerate particle sorting. No sorting
# implementation exists yet for AMD in OpenMC.
OPENMC_NVIDIA_SORT=on
OPENMC_INTEL_SORT=off

####################################################################
# END PREAMBLE
####################################################################

TEST_DIR=$PWD

####################################################################
# Downloads

if [ "$1" = "all" ] || [ "$1" = "download" ]; then

# Clone OpenMC source
git clone --recursive https://github.com/exasmr/openmc.git

# Clone benchmarks repository
git clone https://github.com/jtramm/openmc_offloading_benchmarks.git

# Download and unzip OpenMC's cross section data files
wget https://anl.box.com/shared/static/vht6ub1q27hujkqpz1k0s48lrv44op0v.tgz
tar -xzvf vht6ub1q27hujkqpz1k0s48lrv44op0v.tgz
rm vht6ub1q27hujkqpz1k0s48lrv44op0v.tgz

fi

####################################################################
# Compilation

if [ "$1" = "all" ] || [ "$1" = "compile" ]; then

# Create directories and delete old build/install
cd openmc
rm -rf build
rm -rf install
mkdir build
mkdir install
cd build
cmake --preset=${OPENMC_TARGET} -DCMAKE_INSTALL_PREFIX=../install -Doptimize=on -Ddevice_printf=off -Ddebug=off -Dcuda_thrust_sort=${OPENMC_NVIDIA_SORT} -Dsycl_sort=${OPENMC_INTEL_SORT} ..
make VERBOSE=1 -j8 install

fi

####################################################################
# Setup OpenMC Environment
export LD_LIBRARY_PATH=${TEST_DIR}/openmc/install/lib64:$LD_LIBRARY_PATH
export PATH=${TEST_DIR}/openmc/install/bin:$PATH
export OPENMC_CROSS_SECTIONS=${TEST_DIR}/nndc_hdf5/cross_sections.xml

####################################################################
# Validation (runs a small test problem and checks for correctness)

if [ "$1" = "all" ] || [ "$1" = "validate" ]; then

# Select small benchmark problem
cd ${TEST_DIR}/openmc_offloading_benchmarks/progression_tests/small

TEST_LOG=log.txt
rm ${TEST_LOG}

# Program Launch
openmc --event &>> ${TEST_LOG}

# Begin Result Validation
TEST_RESULT=$(cat ${TEST_LOG}      | grep "Absorption" | cut -d '=' -f 2 | xargs)
EXPECTED_RESULT=$(cat expected_results.txt | grep "Absorption" | cut -d '=' -f 2 | xargs)
echo "Test Result     = "${TEST_RESULT}
echo "Expected Result = "${EXPECTED_RESULT}

# Finish Result Validation
[ "$TEST_RESULT" == "$EXPECTED_RESULT" ]

fi

####################################################################
# Performance Test
# Runs a larger performance oriented test for benchmarking and
# reports a performance figure of merit (FOM)

if [ "$1" = "performance" ]; then

# Select small benchmark problem
cd ${TEST_DIR}/openmc_offloading_benchmarks/progression_tests/XXL

TEST_LOG=log.txt
rm ${TEST_LOG}

# Program Launch
openmc --event &>> ${TEST_LOG}

# Begin Result Validation
TEST_RESULT=$(cat ${TEST_LOG}      | grep "Absorption" | cut -d '=' -f 2 | xargs)
EXPECTED_RESULT=$(cat expected_results.txt | grep "Absorption" | cut -d '=' -f 2 | xargs)
echo "Test Result     = "${TEST_RESULT}
echo "Expected Result = "${EXPECTED_RESULT}

# Compute FOM
FOM=$(cat ${TEST_LOG} | grep "(active" | cut -d '=' -f 2 | cut -d 'p' -f 1 | cut -d ' ' -f 2 | xargs)
echo "FOM = "${FOM}" particles/sec"

# Finish Result Validation
exit [ "$TEST_RESULT" == "$EXPECTED_RESULT" ]

fi
