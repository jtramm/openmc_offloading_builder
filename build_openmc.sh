#!/bin/bash  

####################################################################
# Check for command line argument

if [ $# -eq 0 ]; then
 echo "Command line options:
 all - Does all basic steps (download + compile + small + validate)
 download - only downloads data files
 compile - only compiles (deletes old build and install first)
 validate - runs a small test problem and checks for correctness
 small - runs a small test problem
 performance - runs a large test problem and reports performance
 e.g., \"./build_openmc.sh all\" or \"./build_openmc.sh performance\""
 exit 1
fi

####################################################################
# START PREAMBLE
# NOTE - You may need to edit this section to point to or load
# your specific dependencies (HDF5, CMake, and an OpenMP compiler),
# and to select which offloading target you want.
####################################################################

# HDF5 and CMake dependencies
module load spack
module load cmake
module load hdf5

# Note - If you have manually compiled HDF5, set the HDF5_ROOT
# environment variable to your install location

# Compiler dependency (llvm, oneapi)
# On the Argonne JLSE cluster, use "module load llvm/master-nightly"
module load llvm

# GPU target/compiler selection (full list in OpenMC's main directory
# CmakePrests.json file at:
# https://github.com/exasmr/openmc/blob/openmp-target-offload/CMakePresets.json)
# (some options are llvm_a100, llvm_v100, llvm_mi100, llvm_mi250x, spirv_aot)
OPENMC_TARGET=llvm_a100

# If you are compiling for NVIDIA or Intel, you may want to enable
# use of a vendor library to accelerate particle sorting.
# (Set to on/off).
OPENMC_NVIDIA_SORT=off
OPENMC_INTEL_SORT=off
OPENMC_AMD_SORT=off

# Enable compiler debugging line information (-gline-tables-only)
OPENMC_DEBUG_LINE_INFO=off

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
cmake --preset=${OPENMC_TARGET} -DCMAKE_INSTALL_PREFIX=../install -Doptimize=on -Ddevice_printf=off -Ddebug=${OPENMC_DEBUG_LINE_INFO} -Dcuda_thrust_sort=${OPENMC_NVIDIA_SORT} -Dsycl_sort=${OPENMC_INTEL_SORT} -Dhip_thrust_sort=${OPENMC_AMD_SORT} ..
make VERBOSE=1 install

fi

####################################################################
# Setup OpenMC Environment

export LD_LIBRARY_PATH=${TEST_DIR}/openmc/install/lib64:$LD_LIBRARY_PATH
export PATH=${TEST_DIR}/openmc/install/bin:$PATH
export OPENMC_CROSS_SECTIONS=${TEST_DIR}/nndc_hdf5/cross_sections.xml
export OMP_TARGET_OFFLOAD=MANDATORY

####################################################################
# Small (runs a small test problem)

if [ "$1" = "all" ] || [ "$1" = "small" ]; then

# Select small benchmark problem
cd ${TEST_DIR}/openmc_offloading_benchmarks/progression_tests/small

# Program Launch
openmc --event

fi

####################################################################
# Validation (runs a small test problem and checks for correctness)

if [ "$1" = "all" ] || [ "$1" = "validate" ]; then

# Select small benchmark problem
cd ${TEST_DIR}/openmc_offloading_benchmarks/progression_tests/small

TEST_LOG=log.txt
rm -f ${TEST_LOG}

# Program Launch
openmc --event &>> ${TEST_LOG}
cat ${TEST_LOG}

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
# Runs a larger performance oriented test for benchmarking, checks
# for correctness, and reports a performance figure of merit (FOM)

if [ "$1" = "performance" ]; then

# Select XXL benchmark problem
cd ${TEST_DIR}/openmc_offloading_benchmarks/progression_tests/XXL

TEST_LOG=log.txt
rm -f ${TEST_LOG}

# Program Launch
openmc --event &>> ${TEST_LOG}
cat ${TEST_LOG}

# Begin Result Validation
TEST_RESULT=$(cat ${TEST_LOG}      | grep "Absorption" | cut -d '=' -f 2 | xargs)
EXPECTED_RESULT=$(cat expected_results.txt | grep "Absorption" | cut -d '=' -f 2 | xargs)
echo "Test Result     = "${TEST_RESULT}
echo "Expected Result = "${EXPECTED_RESULT}

# Compute FOM
FOM=$(cat ${TEST_LOG} | grep "(inactive" | cut -d '=' -f 2 | cut -d 'p' -f 1 | cut -d ' ' -f 2 | xargs)
echo "FOM = "${FOM}" particles/sec"

# Finish Result Validation
[ "$TEST_RESULT" == "$EXPECTED_RESULT" ]

fi
