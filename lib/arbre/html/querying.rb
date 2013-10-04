require 'active_support/core_ext/object/blank'

module Arbre
  module Html

    ######
    # Querying mixin

      # Adds querying to the Arbre elements.
      module Querying

        # Finds elements by running a query.
        def find(query)
          Query.new(self).execute(query)
        end

        # Finds all child tags of this element. This operation sees through all elements that
        # are not a tag.
        # @return [ElementCollection]
        def child_tags
          result = ElementCollection.new

          children.each do |child|
            if child.is_a?(Tag)
              result << child
            else
              result.concat child.child_tags
            end
          end

          result
        end

        # Finds all descendant tags of this element. This operation sees through all elements that
        # are not a tag.
        # @return [ElementCollection]
        def descendant_tags
          result = ElementCollection.new

          children.each do |child|
            result << child if child.is_a?(Tag)
            result.concat child.descendant_tags
          end

          result
        end

        # Finds elements by a combination of tag and / or classes.
        def find_by_tag_and_classes(tag = nil, classes = nil)
          tag_matches = ->(el) { tag.nil? || el.tag_name == tag }
          classes_match = ->(el) { classes.nil? || classes.all? { |cls| el.has_class?(cls) } }

          found = []
          children.each do |child|
            if child.is_a?(Tag)
              found << child if tag_matches[child] && classes_match[child]
            end

            found += child.find_by_tag_and_classes(tag, classes)
          end

          ElementCollection.new(found)
        end

        # Finds an element by an ID. Note that only the first element with the specified ID
        # is retrieved.
        def find_by_id(id)
          children.each do |child|
            found = if child.is_a?(Tag) && child.id == id
              child
            else
              child.find_by_id(id)
            end
            return found if found
          end

          nil
        end

      end

    ######
    # Query class

      # Class to find tags from a given root tag / element based on a CSS-like query.
      class Query

        ######
        # Initialization

          def initialize(root)
            @root = root
          end

          attr_reader :root

        ######
        # Constants

          # @api private
          CSS_IDENTIFIER = /[-_a-z][-_a-z0-9]*/

          # @api private
          CSS_SCAN = %r[

            # Child node operator
            (>)?

            \s*

            (?:

              (\*)

              |

              # Tag name
              (#{CSS_IDENTIFIER})?

              # ID
              (?:\#(#{CSS_IDENTIFIER}))?

              # Class
              ((?:\.#{CSS_IDENTIFIER})+)?

              # Pseudo
              ((?::#{CSS_IDENTIFIER})+)?

              # Attributes
              ((?:\[.+?\])+)?

            )

          ]x

        ######
        # Execution

          # Executes the given query.
          def execute(query)
            # Sanitize the query for processing.
            query = query.downcase.squeeze(' ')

            tags = [ root ]

            # Run through all segments in the query and process them one by one.
            query.scan CSS_SCAN do |operator, all, tag, id, classes, pseudos, attributes|
              next unless all || tag || id || classes || pseudos || attributes

              classes = classes.split('.').reject(&:blank?) if classes
              pseudos = pseudos.split(':').reject(&:blank?) if pseudos

              # First process combinations of operator, all and id.
              tags = case operator
              when '>' then find_children(tags, tag, id, classes)
              else find_descendants(tags, tag, id, classes)
              end

              filter_by_pseudos tags, pseudos if pseudos
              filter_by_attributes tags, attributes if attributes
            end

            # Convert to an element collection.
            ElementCollection.new(tags)
          end

        ######
        # Internal methods

          private

          def find_children(tags, tag_name, id, classes)
            children = tags.inject([]) { |result, tag| result += tag.child_tags }

            children.select! { |tag| tag.tag_name == tag_name } if tag_name
            children.select! { |tag| classes.all? { |cls| tag.has_class?(cls) } } if classes
            children.select! { |tag| tag.id == id } if id

            children
          end

          def find_descendants(tags, tag_name, id, classes)
            if id
              # Find all children by ID.
              children = tags.map{ |tag| tag.find_by_id(id) }.compact

              # If a tag or classes are specified as well, filter the children.
              children.select! { |tag| tag.tag_name == tag_name } if tag_name
              children.select! { |tag| classes.all? { |cls| tag.has_class?(cls) } } if classes

              children
            elsif tag_name || classes
              # All descendants matching tag and/or classes.
              tags.inject([]) { |result, tag| result += tag.find_by_tag_and_classes(tag_name, classes) }
            else
              # All descendants.
              tags.inject([]) { |result, tag| result += tag.descendant_tags }
            end
          end

          def filter_by_pseudos(tags, pseudos)
            pseudos.each do |pseudo|
              case pseudo
              when 'first'
                tags.slice! 1..-1
              when 'last'
                tags.slice! 0..-2
              when 'first-child'
                tags.select! do |tag|
                  tag == tag.parent.children.first
                end
              when 'last-child'
                tags.select! do |tag|
                  tag == tag.parent.children.last
                end
              end
            end
          end

          def filter_by_attributes(tags, attributes)
            attributes.scan(/\[(.+?=".+?")\]|\[(.+?)\]/).each do |quoted, simple|
              key, value = (quoted||simple).split('=')
              value = $1 if value =~ /^"(.+?)"$/
              if value
                tags.select! { |tag| tag[key] == value }
              else
                tags.select! { |tag| tag.has_attribute?(key) }
              end
            end
          end

      end

  end
end