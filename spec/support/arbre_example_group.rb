module ArbreExampleGroup

  def arbre(&block)
    Arbre::Context.new assigns, helpers, &block
  end

  def assigns
    @assigns ||= {}
  end

  def helpers
    @helpers ||= {}
  end

end

RSpec.configure { |c| c.include ArbreExampleGroup }