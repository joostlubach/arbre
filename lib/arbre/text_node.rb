require 'erb'

module Arbre

  # A 'raw' text node - it just outputs the HTML escaped version of the string it's
  # built with.
  class TextNode < Element
    builder_method :text_node

    # Builds a raw element from a string.
    def self.from_string(string)
      new.tap { |node| node.build!(string) }
    end

    def children
      @children ||= ElementCollection.new.tap do |children|
        def children.<<(*) raise NotImplementedError end
        def children.add(*) raise NotImplementedError end
        def children.concat(*) raise NotImplementedError end
      end
    end

    attr_reader :text

    def build!(text)
      @text = text.to_s
    end

    def to_s
      text
    end

  end

end