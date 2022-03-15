import Pkg
using JuMP
using Distributions

function NVG(graph, A, B, s)
    #creates NVG, which is put into graph input
    #s is an array representing the intensities for each input value
    #returns nothing
    #changes graph variable 
    for i =(A+1):(B-1)
        if s[i] < s[B] + (s[A]-s[B])*(B-i)/(B-A)
            # join A and B
            # euclidean distance
            graph[A,B] = sqrt((s[A]-s[B])^2 + (A-B)^2)
            graph[B,A] = sqrt((s[A]-s[B])^2 + (A-B)^2)
            # tangent of the view angle
            #graph[A,B] = abs((s[A]-s[B])/(A-B)) + 10^(-8)
            #graph[B,A] = abs((s[A]-s[B])/(A-B)) + 10^(-8)
            # time difference
            #graph[A,B] = abs(A-B)
            #graph[B,A] = abs(A-B)
            return
        end
    end
end

function build_WDPVG(s, numPoints)
    #returns WDPVG
    #s is an array representing the intensities for each input value
    graph = zeros(numPoints, numPoints)
    graph_prime = zeros(numPoints, numPoints)
    s_prime = -s
    WDPVG = zeros(numPoints, numPoints)
    for A=1:numPoints
        for B=1:numPoints
            NVG(graph, A, B, s)
            NVG(graph_prime, A, B, s_prime)
            WDPVG[A,B] = maximum([graph[A,B],graph_prime[A,B]])
        end
    end
    return WDPVG
end


