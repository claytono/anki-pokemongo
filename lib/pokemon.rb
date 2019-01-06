# frozen_string_literal: true

require 'generation'

# Represents a Pokemon as known in the gamemaster file
class Pokemon
  attr_reader :name, :form, :number
  attr_reader :generation, :types

  def initialize(entry, _gamemaster)
    @template_id = entry['templateId']
    @data = entry['pokemonSettings']

    populate_number
    populate_types
    @generation = Generation.new(number)
    @name = titlecase(@data['pokemonId'])
    populate_form
  end

  def types_to_s
    @types.map(&:to_s).join(' & ')
  end

  def form_to_s
    titlecase(@form.to_s)
  end

  def form?
    !@form.nil?
  end

  private

  def populate_number
    m = /^V(\d+)_POKEMON/.match(@template_id)
    @number = m[1].to_i
  end

  def populate_types
    @types = [type_const_to_string(@data['type'])]
    return unless @data.key?('type2')

    @types << type_const_to_string(@data['type2'])
  end

  def populate_form
    @form = nil
    return unless @data.key?('form')

    @form = @data['form'].downcase
    @form = form[(@name.length + 1)..-1].to_sym
  end

  def type_const_to_string(const)
    type = titlecase(const)
    type.gsub!(/Pokemon Type /, '')
  end

  def titlecase(str)
    str.tr('_', ' ').gsub(/\w+/, &:capitalize)
  end
end
