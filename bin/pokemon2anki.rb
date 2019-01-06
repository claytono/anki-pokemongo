#!/usr/bin/ruby

$LOAD_PATH.unshift File.join(File.dirname(__FILE__), '..', 'lib')

require 'json'
require 'pp'
require 'pokemon'

def get_form_asset_id(number, name, form_name, templates)
  return 0 if form_name.nil?
  tid = sprintf("FORMS_V%04d_POKEMON_%s", number, name).upcase
  return 0 unless templates[tid]
  return 0 unless templates[tid]['formSettings']
  return 0 unless templates[tid]['formSettings']['forms']

  forms = templates[tid]['formSettings']['forms'].select do |form|
    form['form'] == form_name
  end
  return 0 if forms.empty?

  return 0 unless forms[0]['assetBundleValue']
  forms[0]['assetBundleValue']
end

def make_img_src(filename)
  if File.exists?(File.join('PogoAssets', 'pokemon_icons', filename))
    return "<img src=\"#{filename}\">"
  end
  return ''
end

def get_form_image_html(number, name, form_name, templates)
  asset_id = get_form_asset_id(number, name, form_name, templates)
  filename = sprintf("pokemon_icon_%03d_%02d.png", number, asset_id)
  shiny_filename = sprintf("pokemon_icon_%03d_%02d_shiny.png", number, asset_id)
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

  image_html, shiny_image_html = get_form_image_html(pokemon.number, mon['pokemonId'], mon['form'], templates)
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
