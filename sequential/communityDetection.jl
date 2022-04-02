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
 

function hubConstruction(g, path)
    # puts each node not in path into group of closest node in path
    # returns list of sets
    groups = Set{Int64}[]
    for y in path
       push!(groups, Set(y)) 
    end
    for x in g.verts
        if !(x in path)
            shortestLen = typemax(Float32)
            #not always returing correct group because of directed graph. 
            #think we need to make graph undirected
            group = 1
            for y in eachindex(path)
                p, c = dijkstrapath(g, x, path[y])
                if c < shortestLen
                    shortestLen = c
                    group = y
                end
            end
        push!(groups[group], x)
        end
    end
    return groups
end


function hubMerging(g, path, groups, e)
    ret = copy(groups)
    
    p_copy = copy(path)
    
    while size(p_copy)[1] > 1
        x = p_copy[1]
        for y in 2:(size(p_copy)[1])
            p, c = dijkstrapath(g, x, p_copy[y])
            if c < e
                ret[1] = union!(ret[1],ret[y])
                deleteat!(ret, y)
                deleteat!(p_copy, y)
            end
        end
        deleteat!(p_copy, 1)
        
    end
    return ret
end