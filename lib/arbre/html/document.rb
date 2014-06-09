module Arbre
  module Html

    # Root tag for any Html document.
    #
    # Represents the combination of a doctype, a +head+ tag and a +body+ tag.
    class Document < Tag

      ######
      # Initialization

        def initialize(*)
          super
        end

      ######
      # Building

        def build!
          prepend_head unless @_head
          append_body unless @_body

          within body do
            yield self if block_given?
          end
        end

        private

        # Builds up a default head tag.
        def prepend_head
          @_head = prepend(Head) do
            meta :"http-equiv" => "Content-Type", :content => "text/html; charset=utf-8"
          end
        end

        # Builds up a default body tag.
        def append_body
          @_body = append(Body)
        end

        public

      ######
      # Head & body accessors

        def document_title
          @title ||= title_tag.content
        end

        def title_tag
          head.find_first('> title') || within(head) { prepend Title }
        end
        private :title_tag

        # Adds content to the head tag and/or returns it.
        def head(&block)
          prepend_head unless @_head

          within @_head, &block if block_given?
          @_head
        end

        # Adds content to the body tag and/or returns it.
        def body(&block)
          append_body unless @_body

          within @_body, &block if block_given?
          @_body
        end

      ######
      # Rendering

        def tag_name
          'html'
        end

        def doctype
          '<!DOCTYPE html>'.html_safe
        end

        def to_s
          out = ActiveSupport::SafeBuffer.new
          out << doctype
          out << "\n\n"
          out << super
        end

    end

  end
end
