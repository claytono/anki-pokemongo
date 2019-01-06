# frozen_string_literal: true

require 'generation'

# Represents a Pokemon as known in the gamemaster file
class Pokemon
  attr_reader :number, :generation

  def initialize(entry, _gamemaster)
    @template_id = entry['templateId']
    @data = entry['pokemonSettings']

    populate_number
    @generation = Generation.new(number)
  end

  private

  def populate_number
    m = /^V(\d+)_POKEMON/.match(@template_id)
    @number = m[1].to_i
  end
end
