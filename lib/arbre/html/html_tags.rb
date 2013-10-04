module Arbre
  module Html

    # This file creates a class for all known HTML 5 tags. You can derive
    # from these classes to build specialized versions.

    AUTO_BUILD_TAGS = %w[
      a abbr address area article aside audio b base
      bdo blockquote body br button canvas caption cite
      code col colgroup command datalist dd del details
      dfn div dl dt em embed fieldset figcaption figure
      footer form h1 h2 h3 h4 h5 h6 head header hgroup
      hr html i iframe img input ins keygen kbd label
      legend li link map mark menu meta meter nav noscript
      object ol optgroup option output pre progress q
      s samp script section select small source span
      strong style sub summary sup table tbody td
      textarea tfoot th thead time title tr ul var video
    ]

    def self.create_tag_class(tag, builder_method = tag.to_sym)
      module_eval <<-RUBY, __FILE__, __LINE__+1
        class #{tag.camelize} < Tag
          builder_method #{builder_method.inspect}

          def tag_name
            #{tag.inspect}
          end
        end
      RUBY
    end

    AUTO_BUILD_TAGS.each do |tag|
      create_tag_class tag
    end

    create_tag_class 'p', :para

    class Table < Tag
      def initialize(*)
        super
        set_table_tag_defaults
      end

      protected

      # Set some good defaults for tables
      def set_table_tag_defaults
        set_attribute :border,      0
        set_attribute :cellspacing, 0
        set_attribute :cellpadding, 0
      end
    end

  end
end
