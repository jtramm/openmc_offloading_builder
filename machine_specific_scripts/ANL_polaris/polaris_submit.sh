#!/bin/bash -l

#PBS -N openmc_scaling
#PBS -l select=1
#PBS -l walltime=0:20:00
#PBS -l filesystems=home
#PBS -q prod
#PBS -A CSC249ADSE08

# Adjust select=n line above to indicate how many
# nodes you want to run on (n=# of nodes)

cd /path/to/problem
./polaris_run.sh
