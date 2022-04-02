import Pkg
using JuMP
using Distributions

include("communityDetection.jl")

function NVG(A, B, s)
    #creates graph edge
    #s is an array representing the intensities for each input value
    #returns weight of graph edge
    for i =(A+1):(B-1)
        if s[i] < s[B] + (s[A]-s[B])*(B-i)/(B-A)
            # join A and B
            # euclidean distance
            edge = sqrt((s[A]-s[B])^2 + (A-B)^2)
            # tangent of the view angle
            #edge= abs((s[A]-s[B])/(A-B)) + 10^(-8)
            # time difference
            #edge = abs(A-B)
            return edge
        end
    end
    return 0
end

function build_WDPVG(s, numPoints)
    #returns WDPVG
    #s is an array representing the intensities for each input value
    #returns list of tuples of each edge
    s_prime = -s
    WDPVG = Tuple{Int64, Int64, Float64}[]
    for A=1:numPoints
        for B=1:numPoints
            graph = convert(Float64, NVG(A, B, s))
            graph_prime = convert(Float64, NVG(A, B, s_prime))
            x = maximum([graph,graph_prime])
            if x != 0
                push!(WDPVG,(A,B,x))
            end
        end
    end
    return WDPVG
end


