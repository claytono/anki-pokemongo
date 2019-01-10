# frozen_string_literal: true

require 'pokemon'
require 'type'

# Represents a Pokemon GO gamemaster data file
class Gamemaster
  attr_reader :gamemaster, :pokemon, :types
  def initialize(filename)
    @filename = filename
    @pokemon = []
    @types = []
  end

  def load
    load_file
    process_entries
  end

  private

  def load_file
    raw_gamemaster = JSON.parse(File.read(@filename))
    @gamemaster = {}
    raw_gamemaster['itemTemplates'].each do |item|
      tid = item['templateId']
      if @gamemaster[tid]
        puts 'Duplicate template!'
        pp item
        exit 1
      end
      @gamemaster[tid] = item
    end
  end

  def process_entries
    @gamemaster.each_value do |item|
      if item.key?('pokemonSettings')
        @pokemon << Pokemon.new(item, @gamemaster)
      elsif item.key?('typeEffective')
        @types << Type.new(item)
      end
    end
  end
end
