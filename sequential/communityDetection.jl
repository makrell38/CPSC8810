import Pkg
using JuMP
using Distributions

# Code adapted from https://rosettacode.org/wiki/Dijkstra%27s_algorithm
struct Digraph{T <: Real,U}
    edges::Dict{Tuple{U,U},T}
    verts::Set{U}
end
 
function Digraph(edges::Vector{Tuple{U,U,T}}) where {T <: Real,U}
    vnames = Set{U}(v for edge in edges for v in edge[1:2])
    adjmat = Dict((edge[1], edge[2]) => edge[3] for edge in edges)
    return Digraph(adjmat, vnames)
end
 
vertices(g::Digraph) = g.verts
edges(g::Digraph)    = g.edges
 
neighbours(g::Digraph, v) = Set((b, c) for ((a, b), c) in edges(g) if a == v)
 
function dijkstrapath(g::Digraph{T,U}, source::U, dest::U) where {T, U}
    @assert source ∈ vertices(g) "$source is not a vertex in the graph"
    
    # Easy case
    if source == dest return [source], 0 end
    # Initialize variables
    inf  = typemax(T)
    dist = Dict(v => inf for v in vertices(g))
    prev = Dict(v => v   for v in vertices(g))
    dist[source] = 0
    Q = copy(vertices(g))
    neigh = Dict(v => neighbours(g, v) for v in vertices(g))
 
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
 

function hubConstruction(g, path, direction)
    # puts each node not in path into group of closest node in path
    # returns list of sets
    # direction sets the direction for grouping
    # direction options are "left", "right", or ""
    # left means nodes are group only with nodes that come before it
    groups = Set{Int64}[]
    dict = Dict{Int64, Set{Int64}}()
    for y in path
       push!(groups, Set(y)) 
    end
    for x in g.verts
        group = x
        if !(x in path) 
            shortestLen = typemax(Float32)
            for y in eachindex(path)
                if direction == "left" && path[y] > x
                    continue
                elseif direction == "right" && path[y] < x
                    continue
                end
                p, c = dijkstrapath(g, x, path[y])
                if c < shortestLen
                    shortestLen = c
                    group = path[y]
                end
            end
        end
        if haskey(dict, group)
            push!(dict[group], x)
        else
            dict[group] = Set(x)
        end
    end
    return dict
end

function hubMerging(g, path, groups, e)
    # merge groups that are closer than e distance apart
    # merges to the left ie later group becomes part of eariler group
    k = sort!(collect(keys(groups)))
    while length(k) >= 2
        first = k[1]
        i = 2
        while i <= length(k)
           second = k[i]
            p,c = dijkstrapath(g, first, second)
            if c < e
                groups[first] = union!(groups[first], groups[second])
                delete!(groups, second)
                deleteat!(k, i)
            else
                i += 1
            end
            
        end
        deleteat!(k, 1)
    end
end

