require 'active_support/inflector'
require 'active_support/dependencies/autoload'
require 'active_support/core_ext/module/delegation'
require 'active_support/core_ext/string/output_safety'

module Arbre
  module Html
  end
end

require 'arbre/element'
require 'arbre/container'
require 'arbre/context'
require 'arbre/text_node'

require 'arbre/element_collection'
require 'arbre/child_element_collection'

require 'arbre/html/attributes'
require 'arbre/html/class_list'
require 'arbre/html/querying'
require 'arbre/html/tag'
require 'arbre/html/comment'
require 'arbre/html/html_tags'
require 'arbre/html/document'

require 'arbre/rails' if defined?(Rails)