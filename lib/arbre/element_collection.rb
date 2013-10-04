module Arbre

  class ElementCollection

    ######
    # Initialization

      def initialize(elements = [])
        @elements = elements.to_a
      end

    ######
    # Array proxy

      include Enumerable
      delegate :each, :empty?, :length, :size, :count, :to => :@elements
      delegate :clear, :to => :@elements

      def [](index)
        @elements[index]
      end

      def add(element)
        @elements << element unless include?(element)
        self
      end
      def <<(element)
        add element
      end

      def concat(elements)
        elements.each do |element|
          self << element
        end
      end

      def remove(element)
        @elements.delete element
      end

      def to_ary
        @elements
      end
      alias to_a to_ary

      def ==(other)
        to_a == other.to_a
      end

      def eql?(other)
        other.is_a?(ElementCollection) && self == other
      end

    ######
    # Set operations

      def +(other)
        self.class.new((@elements + other).uniq)
      end

      def -(other)
        self.class.new(@elements - other)
      end

      def &(other)
        self.class.new(@elements & other)
      end

    ######
    # String conversion

      def to_s
        html_safe_join(map(&:to_s), "\n")
      end

      private

      def html_safe_join(array, delimiter = '')
        ActiveSupport::SafeBuffer.new.tap do |str|
          array.each_with_index do |element, i|
            str << delimiter if i > 0
            str << element
          end
        end
      end

  end

end
