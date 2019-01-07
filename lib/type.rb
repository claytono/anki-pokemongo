# frozen_string_literal: true

# Represents a type and what it is effective against as known in the gamemaster
# file
class Type
  attr_reader :name
  TYPE_ORDER = %w[
    Normal
    Fighting
    Flying
    Poison
    Ground
    Rock
    Bug
    Ghost
    Steel
    Fire
    Water
    Grass
    Electric
    Psychic
    Ice
    Dragon
    Dark
    Fairy
  ].freeze

  def initialize(entry)
    @template_id = entry['templateId']
    @data = entry['typeEffective']

    @name = @data['attackType'].gsub(/POKEMON_TYPE_/, '').titlecase
  end

  # Returns effectiveness multipler against provided type
  def vs(type)
    offset = TYPE_ORDER.find_index(type.name)
    scalar = @data['attackScalar'][offset].round(3)
    [classify_scalar(scalar), scalar]
  end

  private

  def classify_scalar(scalar)
    if (scalar - 1.0).abs < 0.01
      'Neutral'
    elsif (scalar - 1.6).abs < 0.01
      'Super effective'
    elsif (scalar - 0.625).abs < 0.01
      'Not very effective'
    elsif (scalar - 0.390).abs < 0.01
      'No effect'
    else
      'Unknown'
    end
  end
end
