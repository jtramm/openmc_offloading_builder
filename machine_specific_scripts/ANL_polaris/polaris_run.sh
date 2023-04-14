#!/bin/bash

module use /home/jtramm/Modules/modulefiles
module load cmake
module load mpiwrappers/cray-mpich-llvm
module load cudatoolkit-standalone
export HDF5_ROOT=/home/jtramm/hdf5/hdf5_install
module load llvm/release-16.0.0
module load openmc/experimental

NNODES=`wc -l < $PBS_NODEFILE`
NRANKS_PER_NODE=16
NRANKS=$(( $NRANKS_PER_NODE * $NNODES ))
NPARTICLES_PER_RANK=5000000

mpiexec -n ${NNODES} --ppn 1 ./enable_mps_polaris.sh

NPARTICLES=$(( $NRANKS * $NPARTICLES_PER_RANK ))

#mpiexec -n ${NRANKS} --ppn ${NRANKS_PER_NODE} -d 1 /home/jtramm/core-fom-depleted/polaris_launch.sh ${NPARTICLES}
mpiexec -n ${NRANKS} --ppn ${NRANKS_PER_NODE} -d 4 /home/jtramm/core-fom-depleted/polaris_launch.sh ${NPARTICLES}

#openmc --event -s 1 -i 1750000 -n 10000000
#mpiexec -n ${NRANKS} --ppn ${NRANKS_PER_NODE} -d 4 /home/jtramm/core-fom-depleted/polaris_launch.sh ${NPARTICLES}
