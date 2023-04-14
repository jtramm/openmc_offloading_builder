#!/bin/bash
num_gpus=4
gpu=$((${num_gpus} - 1 - ${PMI_LOCAL_RANK} % ${num_gpus}))
echo $gpu
OMP_DEFAULT_DEVICE=$gpu openmc --event -s 4 -i 1500000 -n ${1}
