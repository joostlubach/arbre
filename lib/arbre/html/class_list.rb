require 'set'

module Arbre
  module Html

    # Holds a set of classes
    class ClassList < Set

      # Alias to the list itself.
      def classes
        self
      end

      # Build a new list from a string of classes.
      def self.from_string(classes)
        new.tap { |list| list.add classes }
      end

      # Adds one ore more classes to the list.
      def add(classes)
        classes.to_s.split(' ').each do |klass|
          super klass
        end
        self
      end
      alias << add

      def to_s
        to_a.join(' ')
      end

    end

    def ClassList(classes)
      ClassList.from_string(classes)
    end

  end
end
