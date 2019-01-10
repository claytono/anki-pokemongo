# frozen_string_literal: true

require 'pokemon'
require 'type'

# Represents a Pokemon GO gamemaster data file
class Gamemaster
  attr_reader :gamemaster, :pokemon, :types
  attr_reader :form_families

  def initialize(filename)
    @filename = filename
    @pokemon = []
    @types = []
    @form_families = {}
  end

  def load
    load_file
    process_entries
    process_form_families
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

  def process_form_families
    @form_families = Hash.new { |h, k| h[k] = [] }
    @pokemon.each do |pokemon|
      next unless pokemon.form?

      @form_families[pokemon.name] << pokemon
    end

    # Remove all "normal" entries for pokemon that belong to a family, but don't
    # have a form key.  These are all duplicates.
    @pokemon = @pokemon.reject do |pokemon|
      @form_families.key?(pokemon.name) && !pokemon.form?
    end
  end
end
