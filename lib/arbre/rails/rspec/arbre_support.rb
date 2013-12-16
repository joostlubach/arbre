module Arbre
  module Rails
    module RSpec

      # Adds support for an Arbre context.
      module ArbreSupport

        # Simulates how ArbreTemplateHandler sets up a context, but using the context
        # build block.
        def arbre_context
          @arbre_context ||= Arbre::Context.new(assigns, helpers)
        end
        alias_method :arbre, :arbre_context

        # Override to provide default assigns (or define +let(:assigns) {...}+).
        def assigns
          @assigns ||= {}
        end

        # Override to provide default helpers (or define +let(:helpers) {...}+).
        def helpers
          @helpers ||= build_helpers
        end

        def build_helpers
          helpers = ActionView::Base.new

          # Simulate a default controller & request.
          allow(helpers).to receive(:controller).and_return(controller)
          allow(helpers).to receive(:request).and_return(request)

          # Include all application controller's helpers.
          if defined?(ApplicationController)
            helpers.singleton_class.send :include, ApplicationController._helpers
          end

          # Stub asset_path
          allow(helpers).to receive(:asset_path) { |asset| "/assets/#{asset}" }

          helpers
        end

        def controller
          @controller ||= ActionController::Base.new.tap do |controller|
            controller.request = request
          end
        end

        def request
          @request ||= ActionDispatch::Request.new('rack.input' => '')
        end

      end

    end
  end
end

RSpec.configure do |config|
  config.include Arbre::Rails::RSpec::ArbreSupport, arbre: true
end