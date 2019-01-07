# frozen_string_literal: true

# Implements the CLI interface for the Anki card generation
class CLI
  def initialize(argv)
    @argv = argv
  end

  def run
    gamemaster = JSON.parse(File.read('PogoAssets/gamemaster/gamemaster.json'))
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
    ].join(',')
  end

  def make_img_src(filename)
    if File.exist?(File.join('PogoAssets', 'pokemon_icons', filename))
      return "<img src=\"#{filename}\">"
    end

    ''
  end
end
