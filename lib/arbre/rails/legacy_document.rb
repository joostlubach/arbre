module Arbre
  module Rails

    # This document adds "legacy" ActionView content to the right places.
    class LegacyDocument < Html::Document

      def build!
        super

        head do
          text_node helpers.content_for(:head)
        end
        body do
          text_node helpers.content_for(:layout)
        end
      end

      def to_s
        if request.xhr?
          body.content
        else
          super
        end
      end

    end

  end
end