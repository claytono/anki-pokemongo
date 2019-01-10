# frozen_string_literal: true

require 'generation'

# Represents a Pokemon as known in the gamemaster file
class Pokemon
  attr_reader :name, :form, :number
  attr_reader :generation, :types, :asset_id

  def initialize(entry, gamemaster)
    @template_id = entry['templateId']
    @data = entry['pokemonSettings']

    populate_number
    populate_types
    @generation = Generation.new(number)
    @name = @data['pokemonId'].titlecase
    populate_form
    @asset_id = calculate_asset_id(gamemaster)
  end

  def types_to_s
    @types.map(&:to_s).join(' & ')
  end

  def form_to_s
    @form.to_s.titlecase
  end

  def form?
    !@form.nil?
  end

  # Returns the normal asset filename and the shiny filename
  def asset_filename
    format('pokemon_icon_%<number>03d_%<asset_id>02d.png',
      number: number, asset_id: asset_id)
  end

  def shiny_asset_filename
    format('pokemon_icon_%<number>03d_%<asset_id>02d_shiny.png',
      number: number, asset_id: asset_id)
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

  def calculate_asset_id(gamemaster)
    return 0 unless form?

    # calculate what the form template id would be if it exists
    tid = format('FORMS_V%<number>04d_POKEMON_%<name>s',
      number: number, name: name.upcase)
    forms = gamemaster.dig(tid, 'formSettings', 'forms')
    return unless forms

    # Find the form match if it exists.
    forms = gamemaster[tid]['formSettings']['forms'].select do |form|
      form['form'] == @data['form']
    end

    forms.dig(0, 'assetBundleValue') || 0
  end

  def type_const_to_string(const)
    type = const.titlecase
    type.gsub!(/Pokemon Type /, '')
  end
end
