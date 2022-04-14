import Pkg
using JuMP
using Distributions

include("WDPVG.jl")
include("communityDetection.jl")


#set number of points
numPoints = 300
# creates numPoints between values 0-1
x = rand(Uniform(0,1),1,numPoints)
#s holds output of each x value put into the sin function
s = sin.(x)

@time begin
#call WDPVG which returns the WDPVG list of tuples of edges
WDPVG = build_WDPVG(s, numPoints)
end
    
#println(WDPVG)
#create graph using method from communityDetection.jl
graph = Digraph(WDPVG)

source = 1
destination = numPoints

@time begin
path, cost = dijkstrapath(graph, source, destination)
end
#println("Shortest path from $source to $destination: ", isempty(path) ? "no possible path" : join(path, " → "), " (cost $cost)")

@time begin
groups = hubConstruction(graph, path, "")
end
#println("groups before merge: ", groups)

@time begin
hubMerging(graph, path, groups, 10)
end
#println("groups after merge: ", groups)
