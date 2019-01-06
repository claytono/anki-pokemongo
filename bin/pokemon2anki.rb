#!/usr/bin/ruby

$LOAD_PATH.unshift File.join(File.dirname(__FILE__), '..', 'lib')

require 'json'
require 'pp'
require 'pokemon'

def make_img_src(filename)
  if File.exists?(File.join('PogoAssets', 'pokemon_icons', filename))
    return "<img src=\"#{filename}\">"
  end
  return ''
end

def get_form_image_html(pokemon)
  filename = sprintf("pokemon_icon_%03d_%02d.png", pokemon.number, pokemon.asset_id)
  shiny_filename = sprintf("pokemon_icon_%03d_%02d_shiny.png", pokemon.number, pokemon.asset_id)
  return make_img_src(filename), make_img_src(shiny_filename)
end

def pokemon2csv(tid, mon, templates)
  pokemon = Pokemon.new(templates[tid], templates)
  name = pokemon.name
  if pokemon.form?
    # Normal forms all have two entries, skip the form one.
    return if pokemon.form == :normal
    name += ' ' + pokemon.form_to_s
  end

  image_html, shiny_image_html = get_form_image_html(pokemon)
  puts [name, pokemon.number, pokemon.types_to_s, image_html, shiny_image_html, pokemon.generation].join(',')
end

gamemaster = JSON.parse(File.read('PogoAssets/gamemaster/gamemaster.json'))
templates = {}
gamemaster['itemTemplates'].each do |item|
  tid = item['templateId']
  if templates[tid]
    puts "Duplicate template!"
    pp item
    exit 1
  end
  templates[tid] = item
end

puts "tags:pokemongo,pokemon"
gamemaster['itemTemplates'].each do |item|
  if item.key?('pokemonSettings')
    pokemon2csv(item['templateId'], item['pokemonSettings'], templates)
  end
end
