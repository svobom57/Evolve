require_relative 'graph'
require_relative 'individual'

class Evolution

  def initialize(graph, population_size, crossover_ratio, mutation_ratio, num_of_generations)
    @graph = graph
    @population_size = population_size
    @crossover_ratio = crossover_ratio
    @mutation_ratio = mutation_ratio
    @num_of_generations = num_of_generations
    @population = Array.new(population_size) {
      Individual.new(Array.new(graph.v_size) { rand(2) })
    }
    @best_individual = Individual.new(Array.new(graph.v_size) { 0 })
    # First n individuals will be moved to next generation (n will always be even)
    @elite = ((Math.log10(@population_size).round)*2).to_i
  end

  def print_population(population)
    population.each { |individual| p individual }
  end

  def evolve_min_vertex_cover
=begin
    p fitness(Individual.new([0, 1, 1, 1, 1, 1, 1, 1, 0, 0, 1, 0, 1, 0, 1, 1])) #78
    p fitness(Individual.new([0, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0, 1, 1, 0, 1, 1])) #102
    p fitness(Individual.new([0, 1, 1, 1, 1, 0, 1, 0, 0, 0, 0, 1, 1, 0, 1, 1])) #126
    p fitness(Individual.new([0, 1, 1, 1, 1, 0, 1, 0, 0, 0, 0, 0, 1, 0, 1, 1])) #154
    exit
=end
    @num_of_generations.times do
      fitness_sum = set_fitness_to_population
      raise 'Weak population' if fitness_sum == 0
      selection(fitness_sum)
      if @best_individual.fitness < @population.last.fitness
        @best_individual = @population.last
        p @best_individual
      end
      crossover
      mutate_generation
    end
    set_fitness_to_population
    @population.sort!
    if @best_individual.fitness < @population.last.fitness
      @best_individual = @population.last
    end
    puts
    @best_individual
  end

  private
  def set_fitness_to_population
    @population.inject(0) { |acc, individual| acc + fitness(individual) }
  end

  def fitness(individual)
    # If an individual is elite from previous generation his fitness is already calculated
    # return individual.fitness if individual.fitness > 0
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
    return individual.fitness = 0 if edges_found == 0
    fitness = ((@graph.v_size-marked_vertices)*(subgraph.e_size)*(subgraph.e_size/edges_found.to_f)).round
    fitness /= 10 unless subgraph.e_size == @graph.e_size
    individual.fitness = fitness
  end

  # Selects best individuals for breeding
  # Using roulette-wheel selection: http://www.wikiwand.com/en/Fitness_proportionate_selection
  def selection(fitness_sum)
    normalize(fitness_sum)
    @population.sort!
    normalized_fitness_sum = @population.inject(0) {
        |acc, individual| individual.accumulated_normalized_fitness = acc + individual.normalized_fitness
    }
    epsilon = 0.0000000001
    raise('Accumulated normalized fitness is not 1.0') unless (normalized_fitness_sum - 1.0).abs < epsilon
  end

  # Normalize fitness values for each individual
  def normalize(fitness_sum)
    @population.each { |individual| individual.normalized_fitness = individual.fitness/fitness_sum.to_f }
  end

  def crossover
    offspring = []
    ((@population_size-@elite)/2).times do
      parent1 = get_parent
      parent2 = get_parent
      offspring << parent1.crossover(parent2, @crossover_ratio)
    end
    offspring << @population.last(@elite)
    @population = offspring.flatten
  end

  def get_parent
    r = rand
    @population.find { |individual| individual.accumulated_normalized_fitness > r }
  end

  def mutate_generation
    @population.each { |individual| individual.mutate_generation(@mutation_ratio) }
  end
end
