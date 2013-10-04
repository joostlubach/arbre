module Arbre
  module Html

    # HTML attributes hash. Behaves like a hash with some minor differences:
    #
    # - Indifferent access: everything is stored as strings, but also values.
    # - Setting an attribute to +true+ sets it to the name of the attribute, as per the HTML
    #   standard.
    # - Setting an attribute to +false+ or +nil+ will remove it.
    class Attributes

      def initialize(attributes = {})
        @attributes = {}
        update attributes
      end

      def self.[](*args)
        Attributes.new(Hash[*args])
      end

      def [](attribute)
        @attributes[attribute.to_s]
      end
      def []=(attribute, value)
        if value == true
          @attributes[attribute.to_s] = attribute.to_s
        elsif value
          @attributes[attribute.to_s] = value.to_s
        else
          remove attribute
        end
      end

      def remove(attribute)
        @attributes.delete attribute.to_s
      end

      def update(attributes)
        attributes.each { |k, v| self[k] = v }
      end

      def ==(other)
        to_hash == other.to_hash
      end

      def eql?(other)
        other.is_a?(Attributes) && self == other
      end

      include Enumerable
      delegate :each, :empty?, :length, :size, :count, :to => :@attributes

      def pairs
        map do |name, value|
          "#{html_escape(name)}=\"#{html_escape(value)}\""
        end
      end

      def to_hash
        @attributes
      end

      def to_s
        pairs.join(' ')
      end

      protected

      def html_escape(s)
        ERB::Util.html_escape(s)
      end

    end

  end
end