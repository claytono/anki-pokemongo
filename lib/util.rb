class String
  def titlecase
    tr('_', ' ').gsub(/\w+/, &:capitalize)
  end
end