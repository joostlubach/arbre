require 'spec_helper'

require 'combustion'
require 'bundler/setup'
require 'arbre/rails'

Combustion.path = 'spec/rails'
Combustion.initialize! :action_controller, :action_view do
  config.middleware.use 'Rack::Lint'
end

require 'rspec/rails'
require 'arbre/rails/rspec'