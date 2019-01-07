# frozen_string_literal: true

# Misc utility functions added to String class
class String
  def titlecase
    tr('_', ' ').gsub(/\w+/, &:capitalize)
  end
end
