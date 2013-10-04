module Arbre

  class ElementCollection

    ######
    # Initialization

      def initialize(elements = [])
        @elements = []
      end

    ######
    # Array proxy

      include Enumerable
      delegate :each, :add, :<<, :clear, :to => :@elements

      def remove(element)
        @elements.delete element
      end

      def to_ary
        @elements
      end
      alias to_a to_ary

    ######
    # Set operations

      def +(other)
        self.class.new(@elements + other)
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
        html_safe_join(map(&:to_s))
      end

      private

      def html_safe_join(delimiter = '')
        ActiveSupport::SafeBuffer.tap do |str|
          each_with_index do |element, i|
            str << delimiter if i > 0
            str << element
          end
        end
      end

  end

end
