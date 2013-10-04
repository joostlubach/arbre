module Arbre
  module Rails

    # Adds the concept of partials to Arbre.
    #
    # In fact, the standard ActionView method +render+ is used, but an Arbre context is passed
    # as a local variable into the template. Arbre's template handler will pick this up and
    # re-use it. This allows you to build in the current Arbre context from a partial template.
    #
    # == Usage
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
    module Partials

      # Inserts a partial into the current flow.
      #
      # @param [Hash]     locals
      #   Extra local variables for the partial.
      # @option [Element] context
      #   The context which is used to render the partial. This can be any element, and
      #   is typically the calling element. The partial template may refer to this as
      #   +self+.
      def partial(name, locals = {}, context: self)
        render :partial => name, :locals => locals.merge(:arbre_context => context)
      end

    end

  end
end