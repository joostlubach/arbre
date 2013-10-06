module Arbre
  module Html

    class Comment < Element
      builder_method :comment

      attr_accessor :comment

      def build(comment = nil)
        @comment = comment
      end

      def to_s
        spaces = (' ' * indent_level * Tag::INDENT_SIZE)

        out = ActiveSupport::SafeBuffer.new

        if !comment
          out << '<!-- -->'.html_safe
        elsif comment.include?("\n")
          out << spaces << '<!--'.html_safe
          out << "\n"
          out << indent_comment
          out << "\n"
          out << spaces << '-->'.html_safe
        else
          out << '<!-- '.html_safe << comment << ' -->'.html_safe
        end

        out
      end

      private

      def indent_comment
        ActiveSupport::SafeBuffer.new.tap do |out|
          comment.split("\n").each_with_index.map do |line, index|
            out << "\n" unless index == 0
            out << (' ' * (indent_level+1) * Tag::INDENT_SIZE) << line
          end
        end
      end

    end

  end
end