# Build Script for OpenMP Target GPU Offloading Version of OpenMC

## Step 1

You need to edit the preamble of the script to solve for OpenMC's dependencies:

- HDF5
- CMake
- An OpenMP offloading compiler

The script is self-documenting in where/how to do this. By default, the script
will assume you have HDF5 and CMake installations through spack.

## Step 2

If you are running the script for the first time and wish to download/compile/install
everything from scratch, then you should run the script as:

```
./build_openmc.sh all
```

## Step 3

Once step 2 is complete, you should run the script as:

```
./build_openmc.sh performance
```

## Additional Options

Command line options:
- all: Does all basic steps (download + compile + validate)
- download: only downloads data files
- compile: only compiles (deletes old build and install first)
- validate: runs a small test problem and checks for correctness
- performance: runs a large test problem and reports performance
