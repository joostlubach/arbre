module Arbre
  module Rails

    # Template rendering strategies for Arbre.
    #
    # == Partials
    #
    # Simply use the method {#partial} instead of +render :partial => '...'+.
    #
    # *+edit.html.arb+:*
    #
    #   fieldset do
    #     partial 'fieldset'
    #   end
    #
    # *+_fieldset.html.arb+:*
    #
    #   # Note: `self' is the same `self' as in the template above!
    #   label :something
    #   text_field :something
    #
    # To pass another context than +self+:
    #
    # *+edit.html.arb+:*
    #
    #   form do |form|
    #     fieldset do
    #       partial 'fieldset', context: form
    #     end
    #   end
    #
    # *+_fieldset.html.arb+:*
    #
    #   # Note: `self' is now the form defined in the template above.
    #   label :something
    #   text_field :something
    #
    module Rendering

      # Inserts a partial into the current flow.
      #
      # @param [Hash]     locals
      #   Extra local variables for the partial.
      # @option [Element] context
      #   The context which is used to render the partial. This can be any element, and
      #   is typically the calling element. The partial template may refer to this as
      #   +self+.
      def partial(name, context: self, **locals)
        render :partial => name, :locals => locals.merge(:arbre_context => context)
      end

      # Uses the given arguments to perform an ActionView render. If the result is an Arbre
      # context, instead of treating it as a string, its children are added to the current
      # element.
      def render(*args, locals: {}, **options)
        locals = locals.merge(:arbre_output_context => true)
        result = helpers.render(*args, locals: locals, **options)

        case result
        when Arbre::Context
          # Append all the context's children to the current element. However, watch out as
          # the children collection is modified during this operation. We'll first create
          # a copy.
          current_element.children.concat result.children.to_a
        when Arbre::Element
          current_element.children << result
        else
          current_element.children << TextNode.from_string(result) if result.length > 0
        end
        result
      end

    end

  end
end