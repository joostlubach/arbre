require 'active_support/core_ext/array/extract_options'
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
        # You can also use method {.tag} for the same purpose.
        def tag_name
          raise NotImplementedError, "method `tag_name' not implemented for #{self.class.name}"
        end

        # Override this if you want to give your tag a default ID.
        # You can also use method {.id} for the same purpose.
        def tag_id
        end

        # Override this if you want to give your tag some default classes.
        # You can also use method {.classes} for the same purpose.
        def tag_classes
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

          self.content  = args.first unless args.empty?
          self.id     ||= tag_id

          attributes.update extra

          # Take out attributes that have a corresponding '<attribute>=' method, so that
          # they can be processed better.
          attributes.keys.each do |name|
            next if name.to_s == 'content'
            next if helpers && helpers.respond_to?(:"#{name}=")

            send :"#{name}=", attributes.delete(name) if respond_to?(:"#{name}=")
          end

          # Set all other attributes normally.
          self.attributes.update attributes

          # Add classes now, so as to not overwrite these with a :class argument.
          add_class tag_classes.join(' ') if tag_classes.present?

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
                    self[:#{attribute}] = value
                  end
                RUBY
              end
            end
          end

          # Defines the tag name for this class and derived classes. This is a DSL-alternative to
          # defining method tag_name.
          #
          # == Usage
          #
          # The following two are equivalent:
          #
          #   tag 'div'
          #
          # and
          #
          #   def tag_name
          #     'div'
          #   end
          def tag(tag)
            class_eval <<-RUBY, __FILE__, __LINE__+1
              def tag_name
                #{tag.to_s.inspect}
              end
            RUBY
          end

          # Defines the tag ID attribute for this class and derived classes.
          #
          # == Usage
          #
          # The following two are equivalent:
          #
          #   id 'my-div'
          #
          # and
          #
          #   def build!(*)
          #     super
          #     self.id = 'my-div'
          #   end
          def id(id)
            class_eval <<-RUBY, __FILE__, __LINE__+1
              def tag_id
                #{id.to_s.inspect}
              end
            RUBY
          end

          # Defines the tag (CSS) classes for this class and derived classes.
          #
          # == Usage
          #
          # The following two are equivalent:
          #
          #   classes 'dashboard', 'floatright'
          #
          # and
          #
          #   def build!(*)
          #     super
          #     add_class 'dashboard'
          #     add_class 'floatright'
          #   end
          def classes(*classes)
            classes = classes.flatten.map(&:to_s)
            class_eval <<-RUBY, __FILE__, __LINE__+1
              def tag_classes
                #{classes.inspect}
              end
            RUBY
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
          self[:class].add classes if classes.present?
        end

        def remove_class(classes)
          self[:class].remove classes
          self[:class] = nil if self[:class].empty?
        end

        def classes=(classes)
          self[:class] = classes.present? ? classes : nil
        end

        def classes
          self[:class]
        end

        def has_class?(klass)
          klass.split(' ').all? { |cls| classes.include?(cls) }
        end

        def style
          self[:style]
        end
        def style=(value)
          self[:style] = value
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
          tag_desc << "(#{self.class.name})" if self.class.name.demodulize != tag_name.camelize
          tag_desc << "##{id}" if id
          tag_desc << classes.map{ |cls| ".#{cls}" }.join
          tag_desc << "[type=#{self[:type]}]" if has_attribute?(:type)

          "<#{tag_desc}>"
        end

    end

  end
end
