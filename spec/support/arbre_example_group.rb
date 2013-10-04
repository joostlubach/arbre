module ArbreExampleGroup

  def arbre(&block)
    @context ||= Arbre::Context.new(assigns, helpers)
    @context.instance_exec &block if block_given?
    @context
  end

  def assigns
    @assigns ||= {}
  end

  def helpers
    @helpers ||= {}
  end

end

RSpec.configure { |c| c.include ArbreExampleGroup }