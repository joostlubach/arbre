module Arbre
  module Html

    # A style definition for an HTML element.
    class StyleHash < Hash

      def initialize(value = nil)
        super()

        case value
        when String
          parse value
        when Hash
          update value
        end
      end

      def parse(value)
        value.split(';').reject(&:blank?).each do |pair|
          name, value = pair.split(':', 2)
          next unless name && value
          self[name.strip] = value.strip
        end
      end
      private :parse

      # Alias to the hash itself.
      def style
        self
      end

      # Make sure to store everything as dasherized values.
      def []=(name, value)
        super name.to_s.underscore.dasherize, value
      end
      def [](name)
        super name.to_s.underscore.dasherize
      end

      def update(value)
        value.each { |name, value| self[name] = value }
      end

      def delete(name)
        super name.to_s.underscore.dasherize
      end

      def to_s
        map{ |n, v| "#{n}: #{v};" }.join(' ')
      end

    end

  end
end