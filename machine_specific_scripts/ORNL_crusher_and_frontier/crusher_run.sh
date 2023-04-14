#!/bin/bash
#SBATCH -A CSC404_crusher
#SBATCH -J openmc_scaling
#SBATCH -t 00:20:00
#SBATCH -p batch
#SBATCH -N 24

NNODES=${SLURM_NNODES}
NPARTICLES_PER_NODE=320000000
NPARTICLES=$(( $NNODES * $NPARTICLES_PER_NODE ))
NRANKS=$(( $NNODES * 16 ))

module reset
module use /gpfs/alpine/csc404/proj-shared/openmc/Modules/modulefiles
module load llvm/current
module load openmc/experimental

cd /gpfs/alpine/csc404/proj-shared/openmc/core-fom-depleted

srun -n ${NRANKS} -c2 --ntasks-per-gpu=2 --gpu-bind=closest openmc --event -n $NPARTICLES -i 1000000 -s 2

#NPARTICLES=80000000
#srun -n4 -c2 --ntasks-per-gpu=2 --gpu-bind=closest openmc --event -n $NPARTICLES -i 1000000 -s 2
