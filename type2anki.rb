#!/usr/bin/ruby

require 'json'

types = JSON.parse(File.read('type.json'))

id2name = {}
types.each do |type|
  id2name[type['id']] = type['name'] 
end

types.each do |type|
  type['damage'].each do |vs|
    multiplier = vs['attackScalar']
    case multiplier
    when 1.4
      multiplier = "Super effective (1.4x)"
    when 1.0
      multiplier = "Normal damage (1x)"
    when 0.714
      multiplier = "Not very effective (0.7x)"
    when 0.51
      multiplier = "No effect (half damage)"
    end
    puts "\"#{type['name']} vs #{id2name[vs['id']]}\", #{multiplier}"
  end
end
