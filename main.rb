require_relative 'graph'
require_relative 'evolution'
require_relative 'graph_config'

graph = Graph.new(get_vertices, get_edges)
evolution = Evolution.new(graph, 30, 0.90, 0.05, 1000)
p evolution.evolve_min_vertex_cover
