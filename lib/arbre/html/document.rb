module Arbre
  module Html

    class Document < Tag

      ######
      # Initialization

        def initialize(*)
          super
          arbre_context.try :expose_assigns, self
        end

      ######
      # Building

        def build
          append_head
          append_body
        end

        # Builds up a default head tag.
        def append_head
          @_head = append(Head) do
            meta :"http-equiv" => "Content-type", :content => "text/html; charset=utf-8"
          end
        end

        # Builds up a default body tag.
        def append_body
          @_body = append(Body)
        end

        private :build_head, :build_body

      ######
      # Head & body accessors

        # Adds content to the head tag and/or returns it.
        def head(&block)
          within @_head, &block if block_given?
          @_head
        end

        # Adds content to the body tag and/or returns it.
        def body(&block)
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
          "#{doctype}\n\n#{super}"
        end

    end

  end
end
