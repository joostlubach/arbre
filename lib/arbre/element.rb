require 'arbre/element/building'

module Arbre

  # Base class for all Arbre elements. Rendering is not implemented, and should be implemented
  # by subclasses.
  class Element

    include Building

    ######
    # Initialization

      # Initializes a new Arbre element. Pass an existing Arbre context to re-use it.
      def initialize(arbre_context = Arbre::Context.new)
        @arbre_context = arbre_context
        @children = ChildElementCollection.new
      end

    ######
    # Context

      attr_reader :arbre_context

      def assigns
        arbre_context.assigns
      end

      def helpers
        arbre_context.helpers
      end

    ######
    # Hierarchy

      attr_accessor :parent

      attr_reader :children

      # Removes this element from its parent.
      def remove!
        parent.children.remove self if parent
      end

      def <<(child)
        children << child
      end

      def children?
        @children.any?
      end

      def parent?
        !!@parent
      end

      def orphan?
        !parent?
      end

      # Retrieves all ancestors (ordered from near to far) for this element.
      # @return [ElementCollection]
      def ancestors
        if parent?
          ElementCollection([parent]) + parent.ancestors
        else
          ElementCollection.new
        end
      end

      # Retrieves all descendants (in prefix form) for this element.
      # @return [ElementCollection]
      def descendants
        descendants = []
        children.each do |child|
          next if child.is_a?(TextNode)

          descendants << child
          descendants += child.descendants
        end

        ElementCollection.new(descendants)
      end

      # Finds all child tags of this element. This operation sees through all elements that
      # are not a tag.
      # @return [ElementCollection]
      def child_tags
        result = []
        children.each do |child|
          if child.is_a?(Html::Tag)
            result << child
          else
            result += child.child_tags
          end
        end
        ElementCollection.new(result)
      end

    ######
    # Content

      def content=(content)
        children.clear
        children << TextNode(content)
      end

      def content
        children.to_s
      end

    ######
    # Set operations

      def +(element)
        to_a + element
      end

      def to_a
        ElementCollection.new([self])
      end

    ######
    # Building & rendering

      # Override this method to build your element.
      def build
      end

      def indent_level
        if parent?
          parent.indent_level + 1
        else
          0
        end
      end

      def to_s
        raise NotImplementedError
      end

      alias to_html to_s

      # Provide a clean element description when inspect is used.
      def inspect
        "#<#{self.class.name}:0x#{object_id.to_s(16)}>"
      end

    ######
    # Method missing

      private

      # Access helper methods from any Arbre element through its context.
      def method_missing(name, *args, &block)
        if helpers.respond_to?(name)
          helpers.send(name, *args, &block)
        else
          super
        end
      end

  end
end
