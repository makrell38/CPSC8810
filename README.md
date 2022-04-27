# CPSC8810
Code for the CPSC8810 HPC paper "Performance Analysis: Parallelizing a Visibility Graph Based Temporal Community Detection Algorithm" by Madison Krell, V Sushma-Amara, and Xun Jia.

Julia must be installed to run the code.
Once Julia is installed, run the following commands to download all required packages:
```
julia
using Pgk
Pgk.add("JuMP")
Pgk.add("Distributions")
Pkg.add("Random")
Pkg.add("Distributed")
Pkg.add("SharedArrays")
Pkg.add("Gadfly")
```

Three versions are included, a sequential version, a multi-threading version, and a distributed computing version.
Each folder contains a contructed sin() example. 

To run the sequential sin example, use the following command
```
julia sequential/sinWDPVGExample.jl
```

To run the multi-threading sin example:
```
julia --threads 6 multiThead/sinExample.jl
```
where 6 is the desired number of threads

To run the distributed computing sin example:
```
julia distributed/sinExample.jl
```
The number of processes is set in the WDPVG.jl file.

sequential/parTest.jl will run multiple sin example with different data sizes for all 3 examples and save a plot of the run times.

The datasets directory contains a real-world dataset used for testing. Use the following command to run an example of all 3 versions on the real-world dataset:
```
julia --threads 6 sequential/fileTest.jl
```

gmiaslab-VG_CommunityDetection-68caae2 holds the python code from the paper "Visibility graph based temporal community detection with applications in biological time series" that the sequential code was based off.