import Pkg
include("communityDetection.jl")


function calculateModularityDensity(graph::Digraph{T,U}, groups)where {T, U}
    groupID = collect(keys(groups))
    
    
    Q_md = 0.0    # modularity density
    totalEdges = collect(keys(graph.edges))
    
    for key in groupID
        E_in = 0.0
        E_out = 0.0
        E_total = 0.0
        currComm = collect(get(groups, key, 0))
        numVerts = length(currComm)
    
        for edg in totalEdges
            E_weight = get!(graph.edges, edg, 0.0)
            if (edg[1] in currComm) && (edg[2] in currComm)
                E_in += 1.0 * E_weight
            end
            if (edg[1] in currComm) && !(edg[2] in currComm)
                E_out += 1.0 * E_weight
            end
            E_total += E_weight
        end
        Q_md += (E_in - E_out)/E_total
    end
    println("Modularity Density for this partition is ", Q_md)
end