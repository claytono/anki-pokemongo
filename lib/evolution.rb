# frozen_string_literal: true

require 'pokemon'
require 'type'

# Represents a Pokemon GO evolution
class Evolution
  attr_reader :id
  attr_reader :from, :to
  attr_reader :candy_cost

  def initialize(from, to, candy_cost)
    @from = from
    @to = to
    @candy_cost = candy_cost
    @id = [from.form_id, to.form_id].join('->')
  end

  def self.from_child(child, gamemaster)
    evolutions = []
    child.data['evolutionBranch'].each do |branch|
      if branch.key?('form')
        to = gamemaster.forms[branch['form']]
      else
        to = gamemaster.forms[branch['evolution']]
      end
      evolutions << Evolution.new(child, to, branch['candyCost'])
    end

    evolutions
  end

  def to_s
    "#{from} -> #{to} Cost: #{candy_cost}"
  end
end