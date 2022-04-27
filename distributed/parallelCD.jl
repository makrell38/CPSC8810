import Pkg
using JuMP
using Distributions
using Distributed 
using SharedArrays


# Code adapted from https://rosettacode.org/wiki/Dijkstra%27s_algorithm
@everywhere struct Digraph{T <: Real,U}
    edges::Dict{Tuple{U,U},T}
    verts::Set{U}
end
 
@everywhere function Digraph(edges::Vector{Tuple{U,U,T}}) where {T <: Real,U}
    vnames = Set{U}(v for edge in edges for v in edge[1:2])
    adjmat = Dict((edge[1], edge[2]) => edge[3] for edge in edges)
    return Digraph(adjmat, vnames)
end
 
#vertices(g::Digraph) = g.verts
#edges(g::Digraph)    = g.edges
 
@everywhere neighbours(g::Digraph, v) = Set((b, c) for ((a, b), c) in g.edges if a == v)
 
@everywhere function dijkstrapath(g::Digraph{T,U}, source::U, dest::U) where {T, U}
    @assert source ∈ g.verts "$source is not a vertex in the graph"
    
    
    # Easy case
    if source == dest return [source], 0 end
    # Initialize variables
    inf  = typemax(T)
    dist = Dict(v => inf for v in g.verts)
    prev = Dict(v => v   for v in g.verts)
    dist[source] = 0
    Q = copy(g.verts)
    neigh = Dict(v => neighbours(g, v) for v in g.verts)
 
    # Main loop
    while !isempty(Q)
        u = reduce((x, y) -> dist[x] < dist[y] ? x : y, Q)
        pop!(Q, u)
        if dist[u] == inf || u == dest break end
        for (v, cost) in neigh[u]
            alt = dist[u] + cost
            if alt < dist[v]
                dist[v] = alt
                prev[v] = u
            end
        end
    end
 
    # Return path
    rst, cost = U[], dist[dest]
    if prev[dest] == dest
        return rst, cost
    else
        while dest != source
            pushfirst!(rst, dest)
            dest = prev[dest]
        end
        pushfirst!(rst, dest)
        return rst, cost
    end
end
 

function hubConst(g, path, direction)
    # puts each node not in path into group of closest node in path
    # returns list of sets
    #shared vector to store all groups
    #prevents overwritting issues
    groups = SharedVector{Int64}(length(g.verts))
    dict = Dict{Int64, Set{Int64}}()
    #run in parallel
    @sync @distributed for x in 1:length(g.verts)
        group = x
        if !(x in path)
            shortestLen = typemax(Float32)
            for y in eachindex(path)
                if direction == "left" && path[y] > x
                    continue
                elseif direction == "right" && path[y] < x
                    continue
                end
                p,c = dijkstrapath(g, x, path[y])
                if c < shortestLen
                    shortestLen=c
                    group = path[y]
                end
            end
        end
        groups[x] = group
    end
    
    #loop through each group and move to dictionary
    for x in eachindex(groups)
        if haskey(dict, groups[x])
            push!(dict[groups[x]], x)
        else
            dict[groups[x]] = Set(x)
        end
    end
    
    return dict
end


function hubMerge(g, path, groups, e)
    #merge groups that are closer than e to each other
    k = sort!(collect(keys(groups)))
    for i in 1:length(k)
       for j in i+1:length(k)
           p,c = dijkstrapath(g, k[i], k[j])
            if c < e
                groups[k[i]] = union!(groups[k[i]], groups[k[j]])
                delete!(groups, k[j])
            end
        end
    end
end

