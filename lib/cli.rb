# frozen_string_literal: true

require 'json'
require 'pp'
require 'csv'
require 'slop'

require 'util'
require 'gamemaster'
require 'pronunciation'
require 'assetmanager'

# Implements the CLI interface for the Anki card generation
class CLI
  DEFAULT_GAMEMASTER_PATH = 'PogoAssets/gamemaster/gamemaster.json'
  DEFAULT_PRONUNCIATION_PATH = 'pokemon-pronunciation/pronunciation.json'

  def initialize(argv)
    @argv = argv
    @opts = parse_opts(argv)
    @gamemaster = Gamemaster.new(@opts[:gamemaster])
    @am = AssetManager.new('assets')
  end

  def run
    @pronunciation = PronunciationDecorator.new(@opts[:pronunciation])

    @gamemaster.add_decorator(@pronunciation)
    @gamemaster.load

    export_pokemon if @opts[:pokemon]
    export_types if @opts[:types]
    export_evolutions if @opts[:evolutions]
    @am.collect_assets
  end

  private

  def parse_opts(argv)
    opts = Slop.parse argv do |o|
      o.string '--gamemaster',
        "Path to gamemaster json file (default: #{DEFAULT_GAMEMASTER_PATH})",
        default: DEFAULT_GAMEMASTER_PATH
      o.string '--pronunciation',
        "Path to pronciation json file (default: #{DEFAULT_PRONUNCIATION_PATH})",
        default: DEFAULT_PRONUNCIATION_PATH
      o.string '-o', '--output',
        'Directory for output files (default: output/)',
        default: 'output'
      o.bool '--pokemon', 'Export pokemon data (default: true)',
        default: true
      o.bool '--types', 'Export type effectiveness data (default: true)',
        default: true
      o.bool '--evolutions', 'Export evolutions data (default: true)',
        default: true
      o.boolean '-h', '--help', 'Display help'
    end

    if opts.help?
      puts opts
      exit 1
    end

    opts
  end

  def export_pokemon
    output_file('pokemon') do |f|
      count = 0
      @gamemaster.pokemon.each do |pokemon|
        line = pokemon2csv(pokemon)
        if line
          f.puts line
          count += 1
        end
      end
      puts "Processed #{count} pokemon"
    end
  end

  def export_types
    output_file('types') do |f|
      types = @gamemaster.types
      count = 0
      types.each do |type1|
        types.each do |type2|
          line = type_vs_to_csv(type1, type2)
          next unless line

          f.puts line
          count += 1
        end
      end
      puts "Processed #{count} types"
    end
  end

  def export_evolutions
    output_file('evolutions') do |f|
      @gamemaster.evolutions.each do |evolution|
        f.puts evolution_to_csv(evolution)
      end
      puts "Processed #{@gamemaster.evolutions.length} evolutions"
    end
  end

  def output_file(type)
    filename = File.join(@opts[:output], type + '.csv')
    File.open(filename, 'w') do |f|
      yield f
    end
  end

  def pokemon2csv(pokemon)
    if pokemon.form?
      name = [pokemon.name, pokemon.form_to_s].join(' ')
    else
      name = pokemon.name
    end

    [
      name, pokemon.number, pokemon.types_to_s,
      @am.make_img_src(pokemon.asset_filenames),
      @am.make_img_src(pokemon.shiny_asset_filenames),
      pokemon.generation,
      pokemon.pronunciation,
      pokemon.ipa,
    ].to_csv
  end

  def type_vs_to_csv(type1, type2)
    summary, scalar = type1.vs(type2)
    return if summary == 'Neutral'

    [
      "#{type1.name} vs #{type2.name}",
      "#{summary} (#{scalar}x)",
      @am.make_img_src(type1.asset_filename),
      @am.make_img_src(type2.asset_filename),
    ].to_csv
  end

  def evolution_to_csv(evolution)
    [
      evolution.to.fancy_name,
      evolution.from.fancy_name,
      evolution.candy_cost,
      @am.make_img_src(evolution.to.asset_filenames),
      @am.make_img_src(evolution.from.asset_filenames),
    ].to_csv
  end


end
