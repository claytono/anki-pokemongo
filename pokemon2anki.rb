#!/usr/bin/ruby

require 'json'
require 'pp'

def titlecase(str)
  str.gsub(/_/, ' ').gsub(/\w+/) do |word|
    word.capitalize
  end
end

def number_to_gen(number)
  if number <= 151
    return 'Kanto/Gen1'
  elsif number <= 251
    return 'Johto/Gen2'
  elsif number <= 386
    return 'Hoenn/Gen3'
  elsif number <= 493
    return 'Sinnoh/Gen4'
  elsif number <= 649
    return 'Unova/Gen5'
  elsif number <= 721
    return 'Kalos/Gen6'
  elsif number <= 809
    return 'Gen 7'
  end

  return 'Unknown'
end

def template_id_to_dex_number(name)
  m = /^V(\d+)_POKEMON/.match(name)
  return m[1].to_i
end

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
  number = template_id_to_dex_number(tid)
  type = titlecase(mon['type'])
  if mon.key?('type2')
    type += " & " + titlecase(mon['type2'])
  end
  type.gsub!(/Pokemon Type /, '')

  name = titlecase(mon['pokemonId'])
  if mon['form']
    if mon['form'] =~ /_NORMAL/
      # Normal forms all have two entries, skip the form one.
      return
    end
    name = titlecase(mon['form'])
  end

  gen = number_to_gen(number)
  image_html, shiny_image_html = get_form_image_html(number, mon['pokemonId'], mon['form'], templates)
  puts [name, number, type, image_html, shiny_image_html, gen].join(',')
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
