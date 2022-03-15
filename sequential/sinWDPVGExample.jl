import Pkg
using JuMP
using Distributions

include("WDPVG.jl")

#set number of points
numPoints = 10
# creates numPoints between values 0-1
x = rand(Uniform(0,1),1,numPoints)
#s holds output of each x value put into the sin function
s = sin.(x)
#call WDPVG which returns the WDPVG graph of numPoints x numPoints
WDPVG = build_WDPVG(s, numPoints)
display("text/plain", WDPVG)
println()