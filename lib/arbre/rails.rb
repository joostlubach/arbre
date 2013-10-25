require 'arbre/rails/template_handler'
require 'arbre/rails/legacy_document'
require 'arbre/rails/layouts'
require 'arbre/rails/rendering'

module Arbre
  module Rails
    class << self
      attr_accessor :legacy_document
      def legacy_document
        @legacy_document ||= Rails::LegacyDocument
      end
    end
  end

  class Railtie < ::Rails::Railtie

    initializer "arbre.add_autoload_paths" do |app|
      ActiveSupport::Dependencies.autoload_paths << "#{app.config.root}/app/views/arbre"
    end

    initializer "arbre.add_layout_support" do
      ActionController::Base.send :include, Arbre::Rails::Layouts::ControllerMethods
      Arbre::Context.send :include, Arbre::Rails::Layouts::ContextMethods
    end

    initializer "arbre.register_template_handler" do
      ActionView::Template.register_template_handler :arb, Arbre::Rails::TemplateHandler.new
    end

  end

  Element.send :include, Rails::Rendering
  Element.send :include, Rails::Layouts
end