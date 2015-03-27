require_relative 'individual'
require_relative 'graph'
require 'set'

class Generation

  attr_reader :population, :generation_fitness

  def initialize(size, graph, population = nil)
    @best_individual = nil
    @fitness_invalid = true
    @generation_fitness = 0
    @graph = graph
    @population_size = size
    @population = population.nil? ? generate_population : population
    @elite = 0
    self
  end

  # First n individuals will be moved to next generation (n has to be even)
  def set_elite(n)
    @elite = n
    self
  end

  def best_individual
    return @best_individual unless @fitness_invalid
    set_fitness
    @best_individual
  end

  def set_fitness
    return self unless @fitness_invalid
    @population.each do |individual|
      fitness = fitness(individual)
      individual.fitness = fitness
      @generation_fitness += fitness
      @best_individual = individual if @best_individual.nil? || fitness > @best_individual.fitness
    end
    @fitness_invalid = false
    self
  end

  # Selects best individuals for breeding
  # Using roulette-wheel selection: http://www.wikiwand.com/en/Fitness_proportionate_selection
  def selection
    @population = normalize.sort!
    normalized_fitness_sum = @population.inject(0) {
        |acc, individual| individual.accumulated_normalized_fitness = acc + individual.normalized_fitness
    }
    epsilon = 0.0000000001
    raise('Accumulated normalized fitness is not 1.0') unless (normalized_fitness_sum - 1.0).abs < epsilon
    self
  end

  def crossover(crossover_ratio)
    offspring = []
    ((@population_size-@elite)/2).times do
      parent1 = get_parent
      parent2 = get_parent
      # We can't send 2 same objects into new generation
      if rand > crossover_ratio || parent1==parent2
        offspring << [Individual.new(parent1.genome.clone), Individual.new(parent2.genome.clone)]
      else
        offspring << parent1.crossover(parent2)
      end
    end
    @population.last(@elite).each do |elite|
      offspring << Individual.new(elite.genome.clone)
    end
    Generation.new(@population_size, @graph, offspring.flatten).set_elite(@elite)
  end

  def mutate_generation(mutation_ration)
    @population.each { |individual| individual.mutate(mutation_ration) }
  end

  private
  def generate_population
    Array.new(@population_size) {
      Individual.new(Array.new(@graph.v_size) { rand(2) })
    }
  end

  # Get parent based on his roulette probability
  def get_parent
    r = rand
    @population.find { |individual| individual.accumulated_normalized_fitness > r }
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
    return 0 if edges_found == 0
    fitness = ((@graph.v_size-marked_vertices)*(subgraph.e_size)*(subgraph.e_size/edges_found.to_f)).round
    fitness /= 10 unless subgraph.e_size == @graph.e_size
    fitness
  end

  # Normalize fitness values for each individual
  def normalize
    @population.each { |individual| individual.normalized_fitness = individual.fitness/@generation_fitness.to_f }
  end
end
