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
- CMake version 3.22 or newer
- An OpenMP offloading compiler
  - LLVM Clang version 16 RC1 or newer (see build_llvm.sh section below for instructions on how to compile/install this if needed)
  - Intel OneAPI SDK version 2023.1.0 (2023.x.0.20221013) or newer
  - Other compilers (GCC, AMD AOMP, HPE/Cray, IBM, Nvidia NVHPC) have bugs preventing OpenMC from working with them currently.
- For running on NVIDIA GPUs, CUDA SDK 11.0 or newer
- For running on AMD GPUs, rocm 5.4 or newer 

The script is self-documenting in where/how to do edit the script to declare your specific dependency solutions. By default, the script
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

Note that you can also optionally pass a second argument specifying
a unique name for the openmc install. This allows for multiple installs
to exist at once, for instance if testing the performance of different
versions of OpenMC or different versions of compilers.


For those interested in varying the compiler commands passed to
cmake, it is recommended to directly edit the CMakePresets.json file
to alter an existing preset to your needs or to add another preset
(perhaps one that inherits from an existing one).

Alternatively, you can also overwrite the CMakePresets.json preset
via definition of the following optional varbiables:

- `OPENMC_CXX_FLAGS`

- `OPENMC_LD_FLAGS`

For instance, one may wish to run the script as:

`OPENMC_CXX_FLAGS="-mllvm -scalar-evolution-infer-max-trip-count-from-memory-access=1" OPENMC_LD_FLAGS="-fuse-ld=lld" ./build_openmc.sh compile experimental_flags`

However, it is important to note that these flags are not being appended to the preset flags, rather, they are overwriting them. Thus, in the above example,
one would lose the standard offloading flags for that architecture. You would need to locate the desired preset you wanted to append to in CMakePresets.json
and be sure to include those commands in your definitions. For example, a full redfinition for llvm native with the new flags appended might look like:

`OPENMC_CXX_FLAGS="-Dgsl_CONFIG_CONTRACT_CHECKING_OFF -Wno-tautological-constant-compare -Wno-openmp-mapping -fopenmp -fopenmp-cuda-mode --offload-arch=native -mllvm -scalar-evolution-infer-max-trip-count-from-memory-access=1" OPENMC_LD_FLAGS="-fuse-ld=lld" ./build_openmc.sh compile experimental_flags`

## What the `build_llvm.sh` script does

In the event that you do not have LLVM Clang installed (or your install was
was not built with OpenMP offloading support) this script will allow you to
compile LLVM from source with the needed build options.

The script contains some notes regarding a few areas you'll need to edit
to update install locations for your system.

The script also contains info on what environment variables need to be set
to add LLVM to your environment, along with an example modulefile.

## Additional machine-specific scripts

There are also scripts available in this repository for compiling on several specific supercomputers. These are provided to make it easier for people to know which modules to load on these systems, and to know how to launch OpenMC in its optimal configuration at scale.
