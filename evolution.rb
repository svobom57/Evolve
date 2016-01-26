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
    @best_individual = @population.best_individual
  end

  def evolve_min_vertex_cover
    @num_of_generations.times do |i|
      @population.set_fitness
      population_best = @population.best_individual
      p @best_individual
      @best_individual = population_best if @best_individual.fitness < population_best.fitness
      break if i == @num_of_generations - 1
      @population.selection
      @population = @population.crossover(@crossover_ratio)
      @population.mutate_generation(@mutation_ratio)
    end
    @best_individual
  end

end
