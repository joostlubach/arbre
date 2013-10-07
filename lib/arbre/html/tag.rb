require 'erb'

module Arbre
  module Html

    # HTML tag element. Has attributes and is rendered as a HTML tag.
    class Tag < Element

      ######
      # Initialization

        def initialize(*)
          super

          @attributes = Attributes.new
        end

      ######
      # Attributes

        # Override this to provide a proper tag name.
        def tag_name
          raise NotImplementedError
        end

        attr_reader :attributes

      ######
      # Building

        # Builds a tag.
        #
        # Any remaining keyword arguments that are received by this method are merged
        # into the attributes array. This means that in your subclass, you can use
        # keyword arguments, if you always end with +**extra+ which you pass on to this
        # method.
        #
        # @param [String] content
        #   Any raw content for in the tag.
        # @param [Hash] attributes
        #   HTML attributes to render.
        def build!(*args, **extra)
          attributes = args.extract_options!
          self.content = args.first unless args.empty?

          self.attributes.update attributes
          self.attributes.update extra

          super()
        end

      ######
      # Attributes

        class << self

          # Defines an HTML attribute accessor.
          #
          # == Example
          #
          #   class CheckBox < Tag
          #
          #     def tag_name
          #       'input'
          #     end
          #
          #     attribute :value
          #     attribute :checked, boolean: true
          #
          #     def build
          #       self[:type] = 'checkbox'
          #       self.value = '1'         # equivalent to self[:value] = '1'
          #       self.checked = true      # equivalent to self[:checked] = 'checked'
          #       self.checked = false     # equivalent to self[:checked] = nil, i.e. removes the attribute
          #     end
          #
          #   end
          def attribute(*attributes, boolean: false)
            attributes.each do |attribute|
              if boolean
                class_eval <<-RUBY, __FILE__, __LINE__+1
                  def #{attribute}
                    has_attribute? :#{attribute}
                  end
                  def #{attribute}=(value)
                    self[:#{attribute}] = !!value
                  end
                RUBY
              else
                class_eval <<-RUBY, __FILE__, __LINE__+1
                  def #{attribute}
                    self[:#{attribute}]
                  end
                  def #{attribute}=(value)
                    self[:#{attribute}] = value.to_s
                  end
                RUBY
              end
            end
          end

        end

        def [](attribute)
          attributes[attribute]
        end
        alias_method :get_attribute, :[]

        def []=(attribute, value)
          attributes[attribute] = value
        end
        alias_method :set_attribute, :[]=

        def has_attribute?(name)
          attributes.has_key? name
        end

      ######
      # ID, class, style

        attribute :id
        def generate_id!
          self.id = object_id
        end

        def add_class(classes)
          self[:class].add classes
        end

        def remove_class(classes)
          self[:class].remove classes
        end

        def classes=(classes)
          self[:class] = classes
        end

        def classes
          self[:class]
        end

        def has_class?(klass)
          klass.split(' ').all? { |cls| classes.include?(cls) }
        end

      ######
      # Rendering

        def to_s
          indent opening_tag, content, closing_tag
        end

        private

        def opening_tag
          attrs = " #{attributes}" unless attributes.empty?
          "<#{tag_name}#{attrs}>".html_safe
        end

        def closing_tag
          "</#{tag_name}>".html_safe
        end

        def self_closing_tag
          attrs = " #{attributes}" unless attributes.empty?
          "<#{tag_name}#{attrs}/>".html_safe
        end

        INDENT_SIZE = 2

        def indent(open_tag, child_content, close_tag)
          spaces = (' ' * indent_level * INDENT_SIZE)

          html = ActiveSupport::SafeBuffer.new

          if empty? && self_closing_tag?
            html << spaces << self_closing_tag
          elsif empty? || one_line?
            html << spaces << open_tag << child_content << close_tag
          else
            html << spaces << open_tag << "\n"
            html << child_content << "\n"
            html << spaces << close_tag
          end

          html
        end

        public

        def empty?
          children.empty?
        end

        def one_line?
          children.length == 1 &&
          children.first.is_a?(TextNode) &&
          !children.first.text.include?("\n")
        end

        def self_closing_tag?
          false
        end

      ######
      # Misc

        def inspect
          tag_desc = tag_name
          tag_desc << "##{id}" if id
          tag_desc << classes.map{ |cls| ".#{cls}" }.join
          tag_desc << "[type=#{self[:type]}]" if has_attribute?(:type)

          if self.class.name != tag_name.camelize
            "<#{tag_desc}>"
          else
            "<#{tag_desc}(#{self.class.name})>"
          end
        end

    end

  end
end
