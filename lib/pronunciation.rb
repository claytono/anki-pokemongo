# frozen_string_literal: true

require 'evolution'
require 'pokemon'
require 'type'

Pronunciation = Struct.new(:number, :name, :pronunciation, :ipa)

# Parses and provides lookup for Pokemon pronunciation
class PronunciationDecorator
  def initialize(filename)
    data = JSON.parse(File.read(filename))
    @by_number = {}
    data.each do |pokemon|
      @by_number[pokemon['number']] = Pronunciation.new(
        pokemon['number'],
        pokemon['name'],
        pokemon['pronunciation'],
        pokemon['ipa']
      )
    end
  end

  def decorate(item)
    return item unless item.key?('pokemonSettings')
    number = extract_dex_number(item)
    item['pokemonSettings']['ipa'] = @by_number[number].ipa
    item['pokemonSettings']['pronunciation'] = @by_number[number].pronunciation

    item
  end

  private

  def extract_dex_number(item)
    m = /^V(\d+)_POKEMON/.match(item['templateId'])
    m[1].to_i
  end

end