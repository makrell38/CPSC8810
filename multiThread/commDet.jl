import Pkg
using JuMP
using Distributions
using Base.Threads

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
 
function doWork(g, path, x)
    group = x
    if !(x in path)
        shortestLen = typemax(Float32)
        #not always returing correct group because of directed graph. 
        #think we need to make graph undirected
        for y in eachindex(path)
            p, c = dijkstrapath(g, x, path[y])
            if c < shortestLen
                shortestLen = c
                group = path[y]
            end
        end
    end
    return group
end

function hubConstruction(g, path)
    # puts each node not in path into group of closest node in path
    # returns list of sets
    groups = Vector{Int64}(undef,length(g.verts))
    dict = Dict{Int64, Set{Int64}}()
    @sync for x in g.verts
        Threads.@spawn groups[x] = doWork(g, path, x)
    end
    for x in eachindex(groups)
        if haskey(dict, groups[x])
            push!(dict[groups[x]], x)
        else
            dict[groups[x]] = Set(x)
        end
    end
    return dict
end

function hubMerging(g, path, groups, e)
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
