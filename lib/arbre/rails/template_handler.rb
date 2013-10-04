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
      # _arbre_ctx      = arbre_context rescue nil
      # _arbre_output   = _arbre_ctx.nil?
      # _arbre_ctx    ||= Arbre::Context.new(assigns, self)
      #
      # _arbre_ctx.instance_exec { <template source> }
      #
      # if _arbre_output
      #   _arbre_ctx.to_html
      # else
      #   ''
      # end

      def call(template)
        "_arbre_ctx = arbre_context rescue nil; _arbre_output = _arbre_ctx.nil?; _arbre_ctx ||= Arbre::Context.new(assigns, self); _arbre_ctx.instance_exec { #{template.source}\n}; _arbre_output ? _arbre_ctx.to_html : ''"
      end

    end

  end
end

ActionView::Template.register_template_handler :arb, Arbre::Rails::TemplateHandler.new