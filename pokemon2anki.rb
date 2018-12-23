#!/usr/bin/ruby

require 'json'

def titlecase(str)
  str.gsub(/_/, ' ').gsub(/\w+/) do |word|
    word.capitalize
  end
end

pokemon = JSON.parse(File.read('pokemon.json'))

pokemon['pokemon'].each do |mon|
  type = titlecase(mon['type'])
  if mon.key?('type2')
    type += " & " + titlecase(mon['type2'])
  end
  type.gsub!(/Pokemon Type /, '')

  name = titlecase(mon['pokedex']['pokemonId'])
  if mon['pokedex']['form']
    name = titlecase(mon['pokedex']['form'])
  end
  puts "#{name} Type?,#{type}"
end
