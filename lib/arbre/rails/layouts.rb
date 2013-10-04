module Arbre
  module Rails

    # Provides a content-template / layout-template construct to be used with Arbre.
    #
    # The idea is that the 'content' view defines the type of document to use, through the {ContextMethods#document}
    # method, and that the 'layout' view/views provide post-processing steps to the document, and subsequently render
    # the document class.
    #
    # == Usage example
    #
    # *+app/views/session/new.html.arb+:*
    #
    #   document LoginScreen do
    #     ...
    #   end
    #
    # *+app/views/layouts/application.html.arb+:*
    #
    #   layout do
    #     self.title = "#{self.title} | Application Name"
    #   end
    #
    # In this case, the content template (+session/new.html.arb+) defines that the content document should be a +LoginScreen+
    # class, and provides a block to customize the screen.
    #
    # The layout template (+layouts/application.html.arb+) provides some common steps that should be applied to all pages
    # using this layout. This block is executed *after* the content customization block.
    #
    # == Content block
    #
    # The content block that is specified will be passed to the document class' +build+ method, meaning that it can be used
    # to customize the document in place. However, if the block is not used by the class, it is "instance-exec'd" on the
    # document instance, so that all documents can be customized in a content template.
    #
    # For example, imagine that class +LoginScreen < Arbre::Html::Document+ does not accept or call the block passed into
    # its +build+ method. The following will still be possible:
    #
    # *+app/views/session/new.html.arb+:*
    #
    #   document LoginScreen do
    #     after 'fieldset.password' do
    #       link forgot_password_path, 'forgot password?'
    #     end
    #   end
    module Layouts

      class DocumentAlreadySet < RuntimeError; end
      class DocumentNotFound < RuntimeError; end

      ######
      # ContentDocument class

        # Describes a content document and build options.
        # @api internal
        class ContentDocument

          def initialize(klass_or_reference, build_arguments, content_block)
            @klass_or_reference = klass_or_reference
            @build_arguments = build_arguments
            @content_block = content_block
          end

          def klass
            case @klass_or_reference
            when Class then @klass_or_reference
            else DocumentFactory[@klass_or_reference] or
              raise DocumentNotFound, "document :#{@klass_or_reference} not found"
            end
          end

          attr_reader :build_arguments, :content_block

        end

      ######
      # ControllerMethods concern

        module ControllerMethods
          extend ActiveSupport::Concern

          protected

          # See {ContextMethods#document} below.
          # @api internal
          def arbre_document(klass_or_reference = nil, *build_arguments, &content_block)
            if klass_or_reference
              raise DocumentAlreadySet if @arbre_document

              @arbre_document = ContentDocument.new(klass_or_reference, build_arguments, content_block)
            else
              @arbre_document
            end
          end

        end

      ######
      # HelperMethods

        module ContextMethods

          # Obtains and/or sets the current content document.
          #
          # @overload document
          #   Gets an object representing the content document to create. This is mostly for internal use.
          #
          # @overload document(klass_or_reference, *build_arguments, &content_block)
          #   Specifies a document class and arguments to use. You may optionally customize it using a block.
          #
          #   @param [Symbol|Class] klass_or_reference
          #     The document class to use. Specify a class or a symbol, which is resolved to a class using
          #     {DocumentFactory}.
          #   @param [Array]        build_arguments
          #     Any arguments passed to the document's +build+ method.
          #   @param [Proc]         content_block
          #     A block to be executed as the content block. See {Layouts above} for more info.
          def document(klass_or_reference = nil, *build_arguments, &content_block)
            controller.send :arbre_document, klass_or_reference, *build_arguments, &content_block
          end

          # Provides a layout block to the current view and appends the current document
          # to the current arbre element.
          #
          # @return [Arbre::Html::Document]  The rendered document.
          def layout(&layout_block)
            doc = if document && document.content_block
              # Use the specified document with the specified content block.

              # Detect whether the block is called.
              block_called = false
              content_block = document.content_block
              doc = append(document.klass, *document.build_arguments) do |*args|
                block_called = true
                instance_exec *args, &content_block
              end

              # Call the block anyway if it hasn't been called yet.
              doc.instance_exec &document.block unless block_called
              doc

            elsif document
              # Use the specified document.
              append document.klass, *document.build_arguments
            else
              # Append a generic layout container.
              append Arbre::Rails::DocumentFactory[:layout]
            end

            # Run the layout block unless this is an AJAX request.
            doc.instance_exec &layout_block if layout_block && !doc.xhr?
            doc
          end

        end

    end
  end
end