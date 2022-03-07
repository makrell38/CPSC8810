import Pkg
using JuMP
using Distributions

function NVG(graph, A, B, s)
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

numPoints = 150
x = rand(Uniform(0,1),1,numPoints)
s = sin.(x)
g = zeros(numPoints, numPoints)
gprime = zeros(numPoints, numPoints)
WDPVG = zeros(numPoints, numPoints)
sprime = -s
for A=1:numPoints
    for B=1:numPoints
        NVG(g, A, B, s)
        NVG(gprime, A, B, sprime)
        WDPVG[A,B] = maximum([g[A,B],gprime[A,B]])
    end
end
