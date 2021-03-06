module Arbre

  # This element is a simple container for children. When rendered, it will
  # simply render the children, making this element 'invisible'. Use this
  # class as a placeholder.
  class Container < Element
    def to_s
      content
    end

    def indent_level
      if parent
        parent.indent_level
      else
        0
      end
    end
  end

end