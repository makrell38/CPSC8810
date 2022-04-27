import Pkg
using JuMP
using Distributions
using Gadfly

include("WDPVG.jl")
include("communityDetection.jl")
include("load.jl")
include("../multiThread/WDPVG.jl")
include("../multiThread/commDet.jl")
include("../distributed/WDPVG.jl")
include("../distributed/parallelCD.jl")

#load the data
data = loadData()
#take values of the 4th column ie lead 1 ecg data
numPoints = size(data[[4],:])[2]

# Change number here to adjust how many datapoints there are
numPoints = trunc(Int,numPoints/100)

#print the number of points being used
println(numPoints)
data = data[[4],:]
data = data[1:numPoints]

# run and time sequential version
seqTime = @elapsed begin
    WDPVG = build_WDPVG(data, numPoints)

    source = 1
    destination = numPoints
    graph = Digraph(WDPVG)

    path, cost = dijkstrapath(graph, source, destination)

    groups = hubConstruction(graph, path, "")

    hubMerging(graph, path, groups, 10)
end

println("sequential done: ", seqTime)

# run and time multithreading 
multiTime = @elapsed begin
    WDPVG = build_WDPVG_mul(data, numPoints)
    graph = Digraph(WDPVG)

    source = 1
    destination = numPoints

    path, cost = dijkstrapath(graph, source, destination)

    groups = hubCon(graph, path, "")
    hubMerg(graph, path, groups, 10)
end
println("multiThreading done: ", multiTime)

# run and time distributed
distTime = @elapsed begin
    WDPVG = build_WDPVG_dis(data, numPoints)

    graph = Digraph(WDPVG)
    source = 1
    destination = numPoints

    path, cost = dijkstrapath(graph, source, destination)

    groups = hubConst(graph, path, "")

    hubMerge(graph, path, groups, 10)
end
println("distributed done: ", distTime)

#plot the times in a bar graph
labelList = ["Sequential", "Multi-Threading", "Distributed"]
timeList = [seqTime, multiTime, distTime]
p = plot(x=labelList, y=timeList, Geom.bar, Guide.XLabel("Approach"), Guide.YLabel("Run Time(sec)"), color=labelList, Scale.color_discrete_manual("red", "blue", "green"))

img = SVG("realData.svg")
draw(img, p)