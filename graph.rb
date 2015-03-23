require 'set'

class Graph

  attr_reader :v_size, :e_size

  def initialize(size, edges)
    @v_size = size
    @e_size = 0
    @edges = Array.new(size) { Set.new }
    build_adjacency_matrix(edges)
  end

  # Adds undirected edge
  def add_edge(v1, v2)
    raise "Vertex #{v1} or #{v2} doesn't exist" if v1 < 0 || v1 >= @v_size || v2 < 0 || v2 >= @v_size
    return false if edge_exists?(v1, v2)
    @edges[v1] << v2
    @edges[v2] << v1
    @e_size += 1
    true
  end

  # Returns array of vertices
  def expand_vertex(v)
    raise "Vertex #{v} doesn't exist" if v < 0 || v >= @v_size
    @edges[v].clone
  end

  private
  # Builds undirected graph
  def build_adjacency_matrix(edges)
    edges.each do |pair|
      add_edge(pair[0], pair[1])
    end
  end

  def edge_exists?(v1, v2)
    @edges[v1].include?(v2) || @edges[v2].include?(v1)
  end

end
