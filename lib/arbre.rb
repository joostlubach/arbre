require 'active_support/inflector'
require 'active_support/dependencies/autoload'
require 'active_support/core_ext/module/delegation'
require 'active_support/core_ext/string/output_safety'

module Arbre
  extend ActiveSupport::Autoload

  autoload :Element
  autoload :Context
  autoload :TextNode
  autoload :Container

  module Html
    extend ActiveSupport::Autoload

    autoload :Attributes
    autoload :ClassList
    autoload :Tag
    autoload :Document
    autoload :Query, 'arbre/html/querying'

    require 'arbre/html/html_tags'
  end

end

require 'arbre/railtie' if defined?(Rails)