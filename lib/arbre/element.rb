require 'arbre/element/building'
require 'arbre/html/querying'

module Arbre

  # Base class for all Arbre elements. Rendering is not implemented, and should be implemented
  # by subclasses.
  class Element
    include Building
    include Html::Querying

    ######
    # Initialization

      # Initializes a new Arbre element. Pass an existing Arbre context to re-use it.
      def initialize(arbre_context = Arbre::Context.new)
        @_arbre_context = arbre_context
        @_children = ChildElementCollection.new(self)

        expose_assigns
      end

    ######
    # Context

      def arbre_context
        @_arbre_context
      end

      def assigns
        arbre_context.assigns
      end

      def helpers
        arbre_context.helpers
      end

    ######
    # Hierarchy

      def parent
        @_parent
      end
      def parent=(parent)
        @_parent = parent
      end

      def children
        @_children
      end

      # Removes this element from its parent.
      def remove!
        parent.children.remove self if parent
      end

      def <<(child)
        children << child
      end

      def has_children?
        children.any?
      end

      def empty?
        !has_children?
      end

      def orphan?
        !parent
      end

      # Retrieves all ancestors (ordered from near to far) for this element.
      # @return [ElementCollection]
      def ancestors
        ancestors = ElementCollection.new

        unless orphan?
          ancestors << parent
          ancestors.concat parent.ancestors
        end

        ancestors
      end

      # Retrieves all descendants (in prefix form) for this element.
      # @return [ElementCollection]
      def descendants
        descendants = ElementCollection.new
        children.each do |child|
          descendants << child
          descendants.concat child.descendants
        end

        descendants
      end

    ######
    # Content

      def content=(content)
        children.clear
        case content
        when Element
          children << content
        when ElementCollection
          children.concat content
        else
          children << TextNode.from_string(content.to_s)
        end
      end

      def content
        children.to_s
      end

    ######
    # Set operations

      def +(element)
        if element.is_a?(Enumerable)
          ElementCollection.new([self] + element)
        else
          ElementCollection.new([ self, element])
        end
      end

    ######
    # Building & rendering

      # Override this method to build your element.
      def build!
        yield self if block_given?

        self
      end

      def indent_level
        if parent
          parent.indent_level + 1
        else
          0
        end
      end

      def to_s
        content
      end

      def to_html
        to_s
      end

      # Provide a clean element description when inspect is used.
      def inspect
        "#<#{self.class.name}:0x#{object_id.to_s(16)}>"
      end

    ######
    # Helpers & assigns accessing

      def respond_to?(method, include_private = false)
        super || (helpers && helpers.respond_to?(method))
      end

      private

      # Exposes the assigns from the context as instance variables to the given target.
      def expose_assigns
        assigns.each do |key, value|
          instance_variable_set "@#{key}", value
        end
      end

      # Access helper methods from any Arbre element through its context.
      def method_missing(name, *args, &block)
        if helpers && helpers.respond_to?(name)
          define_helper_method name
          send name, *args, &block
        else
          super
        end
      end

      def define_helper_method(name)
        self.class.class_eval <<-RUBY, __FILE__, __LINE__+1
          def #{name}(*args, &block)
            helpers.send :#{name}, *args, &block
          end
        RUBY
      end

  end
end
