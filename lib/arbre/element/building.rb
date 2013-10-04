module Arbre
  class Element

    # Dynamic module onto which builder methods can be defined.
    module BuilderMethods
    end

    # Element building concern. Contains methods pertaining to building and inserting child
    # elements.
    module Building

      ######
      # Builder methods

        def self.included(klass)
          klass.send :include, BuilderMethods
          klass.send :extend, BuilderMethod
        end

      ######
      # Builder method DSL

        module BuilderMethod

          def builder_method(method_name)
            BuilderMethods.class_eval <<-EOF, __FILE__, __LINE__
              def #{method_name}(*args, &block)
                insert_element ::#{self.name}, *args, &block
              end
            EOF
          end

        end

      ######
      # Building & inserting elements

        # Builds an element of the given class using the given arguments and block, in the
        # same arbre context as this element.
        def build_element(klass, *args, &block)
          element = klass.new(arbre_context)
          within(element) { element.build *args, &block }
          element
        end

        # Builds an element of the given class using the given arguments and block, in the
        # same arbre context as this element, and adds it to the current arbre element's
        # children.
        def insert_element(klass, *args, &block)
          element = klass.new(arbre_context)
          current_element.insert_child element
          within(element) { element.build *args, &block }
          element
        end

      ######
      # Flow

        # Executes a block within the context of the given element, or DOM query.
        def within(element, &block)
          element = find(element).first if element.is_a?(String)
          arbre_context.within_element element, &block
        end

        # Executes a block within the context of the given element, or DOM query. All elements
        # are prepended.
        def prepend_within(element, &block)
          element = find(element).first if element.is_a?(String)
          arbre_context.within_element element do
            arbre_context.with_flow :prepend, &block
          end
        end

        %w(append prepend).each do |flow|
          class_eval <<-RUBY, __FILE__, __LINE__+1
            def #{flow}(klass = nil, *args, &block)
              arbre_context.with_flow :#{flow} do
                insert_element_or_call_block klass, *args, &block
              end
            end
          RUBY
        end

        %w(after before).each do |flow|
          class_eval <<-RUBY, __FILE__, __LINE__+1
            def #{flow}(element, klass = nil, *args, &block)
              element = find(element).first if element.is_a?(String)
              arbre_context.with_flow [ :#{flow}, element ] do
                insert_element_or_call_block klass, *args, &block
              end
            end
          RUBY
        end

        def insert_element_or_call_block(klass, *args, &block)
          if klass
            insert_element klass, *args, &block
          else
            yield
          end
        end
        private :insert_element_or_call_block

        # Inserts a child element at the right place in the child array, taking the current
        # flow into account.
        def insert_child(child)
          case current_flow
          when :append
            children << child

          when :prepend
            children.insert_at 0, child

            # Update the flow - the next element should be added after this one, not be
            # prepended.
            arbre_context.replace_current_flow :after => child

          else
            # flow: [ :before, element ] or [ :after, element ]
            operation, element = flow
            children.send :"insert_#{operation}", element, child

            if operation == :after
              # Now that we've inserted something after the element, we need to
              # make sure that the next element we insert will be after this one.
              arbre_context.replace_current_flow :after => child
            end
          end
        end

      ######
      # Support methods

        # Builds a temporary container using the given block, but doesn't add it to the tree.
        # The block is executed within the current context.
        def temporary(&block)
          build_element Element, &block
        end

        def current_element
          arbre_context.current_element
        end

        def current_arbre_flow
          arbre_context.current_flow
        end

    end

  end
end