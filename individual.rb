class Individual

  attr_reader :genome
  attr_accessor :fitness, :normalized_fitness, :accumulated_normalized_fitness

  def initialize(genome)
    @fitness = 0
    @normalized_fitness = 0
    @accumulated_normalized_fitness = 0
    @genome = genome
    self
  end

  # Returns children of self and individual
  def crossover(individual)
    crossover_point = rand(@genome.length-1)+1
    children = []
    children << Individual.new(@genome[0...crossover_point]+individual.genome[crossover_point...genome.length])
    children << Individual.new(individual.genome[0...crossover_point]+@genome[crossover_point...genome.length])
    children
  end

  def mutate(probability)
    @genome.map! { |bit| rand <= probability ? 1-bit : bit }
  end

  def <=>(o)
    @fitness <=> o.fitness
  end

  def ==(o)
    @genome == o.genome
  end

end
