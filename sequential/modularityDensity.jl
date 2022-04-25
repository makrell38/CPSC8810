import Pkg
include("communityDetection.jl")


function calculateModularityDensity(g::Digraph{T,U}, groups)where {T, U}
    groupID = collect(keys(groups))
    
    
    Q_md = 0.0    #modularity density
    totalEdges = collect(keys(graph.edges))
    
    for key in groupID
        E_in = 0.0
        E_out = 0.0
        currComm = collect(get(groups, key, 0))
        numVerts = length(currComm)
    
        for edg in totalEdges
            if (edg[1] in currComm) && (edg[2] in currComm)
                E_in += 1.0
            end
            if (edg[1] in currComm) && !(edg[2] in currComm)
                E_out += 1.0
            end
        end
        Q_md += (E_in - E_out)/numVerts
    end
    println("Modularity Density for this partition is ", Q_md)
end