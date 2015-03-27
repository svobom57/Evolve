require_relative 'graph'
require_relative 'generation'
require_relative 'individual'

class Evolution

  def initialize(graph, population_size, crossover_ratio, mutation_ratio, num_of_generations)
    @graph = graph
    @crossover_ratio = crossover_ratio
    @mutation_ratio = mutation_ratio
    @num_of_generations = num_of_generations
    @population = Generation.new(population_size, graph)
    @population.set_elite((Math.log10(population_size).round)*2)
    @best_individual = nil
  end

  def evolve_min_vertex_cover
    @num_of_generations.times do |i|
      @population.set_fitness
      population_best = Individual.new(@population.best_individual.genome)
      population_best.fitness = @population.best_individual.fitness
      @best_individual = population_best if @best_individual.nil? || @best_individual.fitness < population_best.fitness
      break if i == @num_of_generations - 1
      @population.selection
      @population = @population.crossover(@crossover_ratio)
      @population.mutate_generation(@mutation_ratio)
    end
    @best_individual
  end

  def fitness_swag(individual)
    # If an individual is elite from previous generation his fitness is already calculated
    # return individual.fitness if individual.fitcness > 0
    # Creates a subgraph from marked vertices
    subgraph = Graph.new(@graph.v_size, [])
    expanded = Set.new
    edges_found = 0
    marked_vertices = 0
    individual.genome.each_with_index do |marked, vertex1|
      if marked == 1
        expanded = @graph.expand_vertex(vertex1)
        marked_vertices += 1
      end
      expanded.each do |vertex2|
        subgraph.add_edge(vertex1, vertex2)
        edges_found += 1
      end
      expanded.clear
    end
    return 0 if edges_found == 0
    fitness = ((@graph.v_size-marked_vertices)*(subgraph.e_size)*(subgraph.e_size/edges_found.to_f)).round
    fitness /= 10 unless subgraph.e_size == @graph.e_size
    fitness
  end


end
