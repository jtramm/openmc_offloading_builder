#!/bin/bash

# Load command line arguments
NPARTICLES=${1}
NRANKSPERTILE=${2}

# As we are running multiple ranks per tile, we need to manually specify
# the affinity of each MPI rank to assign them to tiles
# The below logic assigns ranks to fill up each tile fully and then
# each card fully before moving onto the next card. E.g.:
# Ranks 0-3:  PVC 0, Tile 0
# Ranks 4-7:  PVC 0, Tile 1
# Ranks 8-11: PVC 1, Tile 0

CARD=0
TILE=0
LOCAL_RANK=${PALS_LOCAL_RANKID}
NRANKSPERCARD=$(( $NRANKSPERTILE * 2 ))

CARD=$(( $LOCAL_RANK / $NRANKSPERCARD ))
CARD_RANK=$(( $LOCAL_RANK - $CARD * $NRANKSPERCARD))
TILE=$(( $CARD_RANK / $NRANKSPERTILE ))

export ZEX_NUMBER_OF_CCS=0:4

# Assign 8 MPI ranks for each card
export ZE_AFFINITY_MASK=${CARD}.${TILE}

echo "Rank ID $LOCAL_RANK will run on GPU $CARD tile $TILE. ZE_AFFINITY_MASK = $ZE_AFFINITY_MASK. ZEX_NUMBER_OF_CCS = $ZEX_NUMBER_OF_CCS"

# Debugging Run
#if [ $PMIX_RANK -eq 623 ]
#then
	#LIBOMPTARGET_DEBUG=1 gdb-oneapi -ex=r --args openmc --event -s 1 -i 775000 -n ${1}
#	gdb-oneapi -ex=r --args openmc --event -s 1 -i 775000 -n ${1}
#else
#	openmc --event -s 1 -i 775000 -n ${1}
#fi
	
# Regular Run
openmc --event -s 2 -i 1000000 -n ${NPARTICLES} --no-sort-non-fissionable-xs

# Device Profiling Run
#onetrace -d -v openmc --event -s 2 -i 775000 -n ${1} &> onetrace_${LOCAL_RANK}.txt

# Host API profiling Run
#onetrace -h openmc --event -s 2 -i 775000 -n ${1} &> host_onetrace_${LOCAL_RANK}.txt

# All Debug
#export FI_CXI_DEFAULT_CQ_SIZE=131072
#export FI_CXI_OVFLOW_BUF_SIZE=8388608
#export FI_CXI_CQ_FILL_PERCENT=20

#gdb-oneapi -ex=r --args openmc --event -s 1 -i 775000 -n ${1}
#gdb-oneapi -ex=r --args openmc -s 2 -i 775000 -n ${1}
#openmc -s 2 -i 775000 -n ${1}
