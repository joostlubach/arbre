module Arbre
  module Rails

    # Template handler capable of re-using an arbre context. If the method or local variable +arbre_context+
    # yields an Arbre context, it is re-used. Note that this may very well be an element as well. The template
    # source is executed on the found 'context' or on a new {Arbre::Context} if it was not found.
    #
    # @see Partials
    class TemplateHandler

      # Readable version:
      #
      # _arbre_reuse_context = defined?(arbre_context)
      # _arbre_ctx = _arbre_reuse_context ? arbre_context : Arbre::Context.new(assigns, self)
      # _arbre_ctx.instance_exec { <template source> }
      #
      # if _arbre_reuse_context
      #   ''
      # elsif defined?(arbre_output_context)
      #   _arbre_ctx
      # else
      #   _arbre_ctx.to_html
      # end

      def call(template)
        "_arbre_reuse_context = defined?(arbre_context); _arbre_ctx = _arbre_reuse_context ? arbre_context : Arbre::Context.new(assigns, self); _arbre_ctx.instance_exec { #{template.source}\n}; _arbre_reuse_context ? '' : defined?(arbre_output_context) ? _arbre_ctx : _arbre_ctx.to_html"
      end

    end

  end
end