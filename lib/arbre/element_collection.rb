module Arbre

  # Stores a collection of Element objects
  class ElementCollection < Array

    def +(other)
      self.class.new(super)
    end

    def -(other)
      self.class.new(super)
    end

    def &(other)
      self.class.new(super)
    end

    def render
      self.collect do |element|
        element.render
      end.join('').html_safe
    end
  end

end
