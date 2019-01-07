# frozen_string_literal: true

require 'json'
require 'pp'
require 'csv'
require 'slop'

require 'pokemon'

# Implements the CLI interface for the Anki card generation
class CLI
  DEFAULT_GAMEMASTER_PATH = 'PogoAssets/gamemaster/gamemaster.json'

  def initialize(argv)
    @argv = argv
    @opts = parse_opts(argv)
  end

  def run
    gamemaster = JSON.parse(File.read(@opts[:gamemaster]))
    templates = {}
    gamemaster['itemTemplates'].each do |item|
      tid = item['templateId']
      if templates[tid]
        puts 'Duplicate template!'
        pp item
        return
      end
      templates[tid] = item
    end

    gamemaster['itemTemplates'].each do |item|
      next unless item.key?('pokemonSettings')

      pokemon = Pokemon.new(item, templates)
      line = pokemon2csv(pokemon)
      puts line if line
    end
  end

  private

  def parse_opts(argv)
    opts = Slop.parse argv do |o|
      o.string '-g', '--gamemaster',
        "Path to gamemaster json file (default: #{DEFAULT_GAMEMASTER_PATH})",
        default: DEFAULT_GAMEMASTER_PATH
      o.boolean '-h', '--help', "Display help"
    end

    if opts.help?
      puts opts
      exit 1
    end

    return opts
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
