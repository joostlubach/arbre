require 'set'

module Arbre
  module Html

    # Holds a set of classes
    class ClassList < Set

      def initialize(classes = [])
        super()
        [*classes].each do |cls|
          add cls
        end
      end

      # Alias to the list itself.
      def classes
        self
      end

      # Adds one ore more classes to the list. You can pass in a string which is split by space, or
      # an array of some kind.
      def add(classes)
        classes = classes.split(' ')
        classes.each { |cls| super cls }
        self
      end
      alias << add

      def remove(classes)
        classes = classes.split(' ')
        classes.each { |cls| delete cls }
        self
      end
      private :delete

      def to_s
        to_a.join(' ')
      end

    end

  end
end
