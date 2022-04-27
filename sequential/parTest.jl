import Pkg
using JuMP
using Distributions
using Random
using Gadfly

include("WDPVG.jl")
include("communityDetection.jl")
include("../multiThread/WDPVG.jl")
include("../multiThread/commDet.jl")
include("../distributed/WDPVG.jl")
include("../distributed/parallelCD.jl")

Random.seed!(123)

#set number of points to test
numPoints = [10,50,100, 250, 500, 1000, 2500]

# keep track of runtimes for plotting
timeList = []
multiList = []
distList = []
numList = []

for i in numPoints
    println(i)
    # creates numPoints between values 0-1
    x = rand(Uniform(0,1),1,i)
    #s holds output of each x value put into the sin function
    s = sin.(x)

    #time sequential version
    count = @elapsed begin
        println("seq ", i)
        #call WDPVG which returns the WDPVG list of tuples of edges
        WDPVG = build_WDPVG(s, i)

        #println(WDPVG)
        #create graph using method from communityDetection.jl
        graph = Digraph(WDPVG)

        source = 1
        destination = i

        path, cost = dijkstrapath(graph, source, destination)


        groups = hubConstruction(graph, path, "")

        hubMerging(graph, path, groups, 10)
    end
    
    push!(timeList, count)
    
    #time multithreading version
    count = @elapsed begin
        println("multi ", i)
        WDPVG = build_WDPVG_mul(s, i)
        graph = Digraph(WDPVG)

        source = 1
        destination = i

        path, cost = dijkstrapath(graph, source, destination)
    
        groups = hubCon(graph, path, "")
        hubMerg(graph, path, groups, 10)
    end
    push!(multiList, count)

    #time distributed version
    count = @elapsed begin
        println("dist ", i)
        WDPVG = build_WDPVG_dis(s, i)

        graph = Digraph(WDPVG)
        source = 1
        destination = i

        path, cost = dijkstrapath(graph, source, destination)

        groups = hubConst(graph, path, "")

        hubMerge(graph, path, groups, 10)
    end
    push!(distList, count)
    push!(numList, i)
    println(i, " done")
    
    #plot times
    seq = layer(x=numList,y=timeList, Geom.line, Geom.point, color=[colorant"red"])
    mul = layer(x=numList,y=multiList, Geom.line, Geom.point, color=[colorant"blue"])
    dis = layer(x=numList,y=distList, Geom.line, Geom.point, color=[colorant"green"])
    p = plot(seq,mul,dis, Guide.XLabel("Data Size"), Guide.YLabel("Run Time(sec)"), Guide.Title("Run Time Comparisons"), Guide.manual_color_key("Legend", ["Sequential", "Multi-Threading","Distributed"], ["red", "blue", "green"]) )

    #save the plot
    img = SVG("runtime.svg")
    draw(img, p)

end

