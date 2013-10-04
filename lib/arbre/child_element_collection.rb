module Arbre

  # An element collection used to hold some other element's children. Adds functionality to
  # update a child's parent when it is added, and supports inserting at specific positions
  # in the collection.
  class ChildElementCollection < ElementCollection

    ######
    # Initialization

      def initialize(parent)
        super([])
        @parent = parent
      end

      attr_reader :parent

    ######
    # Equality

      def ==(other)
        parent == other.parent && super
      end

      def eql?(other)
        parent == other.parent && super
      end

    ######
    # Adding and removing

      def add(element)
        assign_to_parent element unless include?(element)
        @elements << element
      end
      alias << add

      def concat(collection)
        collection.each { |element| self << element }
      end

      def remove(element)
        return unless include?(element)

        element.parent = nil
        @elements.delete element
      end

      def clear
        @elements.each { |element| element.parent = nil }
        super
      end

    ######
    # Inserting

      def insert_after(existing, element)
        index = @elements.index(existing) or
          raise ArgumentError, "existing element #{existing} not found"

        insert_at index+1, element
      end

      def insert_before(existing, element)
        index = @elements.index(existing) or
          raise ArgumentError, "existing element #{existing} not found"

        insert_at index+1, element
      end

      def insert_at(index, element)
        assign_to_parent element unless include?(element)
        @elements.insert index, element
      end

    ######
    # Parent

      private

      # Assigns the element to the parent of this collection, and removes it from the
      # children of its current parent.
      def assign_to_parent(element)
        element.remove!
        element.parent = parent
      end

  end

end