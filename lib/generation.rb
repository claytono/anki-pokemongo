# frozen_string_literal: true

# Represents a Pokemon generation name and number
class Generation
  attr_reader :name, :number

  GEN_RANGES = [
    [151, 'Kanto', 1],
    [251, 'Johto', 2],
    [386, 'Hoenn', 3],
    [493, 'Sinnoh', 4],
    [649, 'Unova', 5],
    [721, 'Kalos', 6],
    [809, 'Alola', 7],
  ].freeze

  def initialize(number)
    @name = 'Unknown'
    @number = nil
    GEN_RANGES.each do |gen_range|
      if number <= gen_range[0]
        @name, @number = gen_range[1..2]
        break
      end
    end
  end

  def to_s
    if @name
      if @number
        [@name, number_to_s].join('/')
      else
        @name
      end
    else
      number_to_s
    end
  end

  private

  def number_to_s
    "Gen#{@number}"
  end
end
