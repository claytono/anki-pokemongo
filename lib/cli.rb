# frozen_string_literal: true

require 'json'
require 'pp'
require 'csv'
require 'slop'

require 'util'
require 'pokemon'

# Implements the CLI interface for the Anki card generation
class CLI
  DEFAULT_GAMEMASTER_PATH = 'PogoAssets/gamemaster/gamemaster.json'

  def initialize(argv)
    @argv = argv
    @opts = parse_opts(argv)
  end

  def run
    read_gamemaster
    export_pokemon
  end

  private

  def parse_opts(argv)
    opts = Slop.parse argv do |o|
      o.string '-g', '--gamemaster',
        "Path to gamemaster json file (default: #{DEFAULT_GAMEMASTER_PATH})",
        default: DEFAULT_GAMEMASTER_PATH
      o.string '-o', '--output',
        'Directory for output files (default: output/)',
        default: 'output'
      o.boolean '-h', '--help', 'Display help'
    end

    if opts.help?
      puts opts
      exit 1
    end

    opts
  end

  def read_gamemaster
    raw_gamemaster = JSON.parse(File.read(@opts[:gamemaster]))
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

  def export_pokemon
    output_file('pokemon') do |f|
      pokemon_count = 0
      @gamemaster.each_pair do |tid, item|
        next unless item.key?('pokemonSettings')

        pokemon = Pokemon.new(item, @gamemaster)
        line = pokemon2csv(pokemon)
        if line
          f.puts line
          pokemon_count += 1
        end
      end
      puts "Processed #{pokemon_count} pokemon"
    end
  end

  def output_file(type)
    filename = File.join(@opts[:output], type + '.csv')
    File.open(filename, 'w') do |f|
      yield f
    end
  end

  def pokemon2csv(pokemon)
    name = pokemon.name
    # Normal forms all have two entries, skip the form one.
    if pokemon.form?
      return if pokemon.form == :normal

      name += ' ' + pokemon.form_to_s
    end

    [
      name, pokemon.number, pokemon.types_to_s,
      make_img_src(pokemon.asset_filename),
      make_img_src(pokemon.shiny_asset_filename),
      pokemon.generation,
    ].to_csv
  end

  def make_img_src(filename)
    if File.exist?(File.join('PogoAssets', 'pokemon_icons', filename))
      return "<img src=\"#{filename}\">"
    end

    ''
  end
end
