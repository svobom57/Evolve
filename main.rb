require_relative 'graph'
require_relative 'evolution'
require_relative 'graph_config'
require 'benchmark'

graph = Graph.new(get_vertices, get_edges)
evolution = Evolution.new(graph, 20, 0.90, 0.05, 100)
iterations = 10
Benchmark.bm() do |bm|
  bm.report do
    iterations.times do
      p evolution.evolve_min_vertex_cover
    end
  end
end
