## What the `build_openmc.sh` script does

This script is capable of downloading the OpenMC source, a set of 
OpenMC data files required to run simulations, and a small repository
of benchmarks for testing the OpenMP offloading capabilities of OpenMC on GPU.
The script is also capable of compiling OpenMC and running a few different simulation
problems, some with validation capabilites to ensure that it is working.

Specific instructions for using this script are given below

## Step 1

You need to edit the preamble of the script to solve for OpenMC's dependencies:

- HDF5
- CMake
- An OpenMP offloading compiler

The script is self-documenting in where/how to do this. By default, the script
will assume you have HDF5 and CMake installations through spack. If you need
more help or info regarding these dependencies, see OpenMC's main installation
documentation: https://docs.openmc.org/en/stable/usersguide/install.html#prerequisites

## Step 2

If you are running the script for the first time and wish to download/compile/install
everything from scratch, then you should run the script as:

```
./build_openmc.sh all
```

By default, this will download/install everything in the directory where the script
was run from.

## Step 3

If step 2 completes and validation passes, then you can begin testing
a larger, more realistic problem via:

```
./build_openmc.sh performance
```

Which will run the Hoogenboom-Martin "large" depleted fuel reactor benchmark.


## Additional Options

Command line options:
- `all`: Does all basic steps (download + compile + validate)
- `download`: only downloads data files
- `compile`: only compiles (deletes old build and install first)
- `small`: runs a small test problem
- `validate`: runs a small test problem and checks for correctness
- `performance`: runs a large test problem and reports performance

## What the `build_llvm.sh` script does

In the event that you do not have LLVM Clang installed (or your install was
was not built with OpenMP offloading support) this script will allow you to
compile LLVM from source with the needed build options.

The script contains some notes regarding a few areas you'll need to edit
to update install locations for your system.

The script also contains info on what environment variables need to be set
to add LLVM to your environment, along with an example modulefile.
