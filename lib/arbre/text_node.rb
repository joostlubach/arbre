require 'erb'

module Arbre

  # A 'raw' text node - it just outputs the HTML escaped version of the string it's
  # built with.
  class TextNode < Element
    builder_method :text_node

    # Builds a raw element from a string.
    def self.from_string(string)
      new.tap { |node| node.build(string) }
    end

    def children
      ElementCollection.new
    end

    attr_reader :text

    def build(text)
      @text = text.to_s
    end

    def to_s
      ERB::Util.html_escape(@text)
    end

  end

  def TextNode(text)
    TextNode.from_string(text)
  end

end