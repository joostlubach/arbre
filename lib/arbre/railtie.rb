require 'arbre/rails/template_handler'
require 'arbre/rails/layouts'
require 'arbre/rails/rendering'

module Arbre
  class Railtie < ::Rails::Railtie

    initializer "arbre.add_layout_support" do
      ActionController::Base.send :include, Arbre::Rails::Layouts::ControllerMethods
      Arbre::Context.send :include, Arbre::rails::Layouts::ContextMethods
    end

    initializer "arbre.register_template_handler" do
      ActionView::Template.register_template_handler :arb, Arbre::Rails::TemplateHandler.new
    end

  end

  Element.send :include, Rails::Rendering
  Element.send :include, Rails::Layouts
end