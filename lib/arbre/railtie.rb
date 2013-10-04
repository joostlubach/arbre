require 'arbre/rails'

module Arbre
  class Railtie < Rails::Railtie

    initializer "arbre.add_layout_support" do
      ActionController::Base.send :include, Arbre::Rails::Layouts::ControllerMethods
      Arbre::Context.send :include, Arbre::rails::Layouts::ContextMethods
    end

  end
end