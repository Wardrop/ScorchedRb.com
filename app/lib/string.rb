class String
  def snake_to_titlecase
    self.gsub('_', ' ').titlecase
  end
end