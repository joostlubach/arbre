module Arbre
  module Html

    ######
    # Querying mixin

      # Adds querying to the Arbre elements.
      module Querying

        # Finds elements by running a query.
        def find(query)
          Query(current_arbre_element, query)
        end

        # Finds elements by a combination of tag and / or classes.
        def find_by_tag_and_classes(tag = nil, classes = nil)
          tag_matches = ->(el) { tag.nil? || el.tag_name == tag }
          classes_match = ->(el) { classes.nil? || classes.all? { |c| el.has_class?(c) } }

          found = []
          children.each do |child|
            found << child if tag_matches[child] && classes_match[child]
            found += find_by_tag_and_classes(child, tag, classes)
          end

          ElementCollection.new(found)
        end

        # Finds an element by an ID. Note that only the first element with the specified ID
        # is retrieved.
        def find_by_id(id)
          children.each do |child|
            next if child.is_a?(TextNode)

            found = if child.respond_to?(:id) && child.id == id
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

            # Start with all child tags of the root element.
            tags = root.child_tags

            # Run through all segments in the query and process them one by one.
            query.scan CSS_SCAN do |operator, all, tag, id, classes, pseudos, attributes|
              next unless all || tag || id || classes || pseudos || attributes

              classes = classes.split('.').reject(&:blank?) if classes
              pseudos = pseudos.split(':').reject(&:blank?) if pseudos

              # First process combinations of operator, all and id.
              tags = case operator
              when '>' then find_children(tag, id, classes)
              else find_descendant(tag, id, classes)
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

          def find_children(tags, tag, id, classes)
            children = tags.inject([]) { |result, tag| result += tag.child_tags }

            children.select! { |tag| tag.tag_name == tag } if tag
            children.select! { |tag| classes.all? { |cls| tag.has_class?(cls) } } if classes
            children.select! { |tag| tag.id == id } if id

            children
          end

          def find_descendants(tags, tag, id, classes)
            if id
              # Find all children by ID.
              children = tags.map{ |t| t.find_by_id(tag, id) }.compact

              # If a tag or classes are specified as well, filter the children.
              children.select! { |t| t.tag_name == tag } if tag
              children.select! { |t| classes.all? { |cls| t.has_class?(cls) } } if classes

              children
            elsif tag || classes
              # All descendants matching tag and/or classes.
              tags.inject([]) { |r, t| r += t.find_by_tag_and_classes(tag, classes) }
            else
              # All descendants.
              tags.inject([]) { |r, t| r += t.descendants }
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

      # Query method access.
      def Query(root, query)
        Query.new(root).execute(query)
      end

  end
end