module Arbre
  module RSpec

    # Used to match JS snippets in HTML content. The JS is canonized as much as possible, so that you don't have to
    # worry about whitespace. Use '(...)' as a wildcard. You may even place text in the wildcard for
    # readability: '(... some wildcard ...)'.
    #
    # == Examples
    #
    #   expect(document.body).to contain_script('Flux.Application.initialize()')
    #   expect(document.body).to contain_script('Flux.Application.initialize((... args ...))')
    class ContainScriptMatcher

      def initialize(expected)
        @expected = expected
      end

      attr_reader :expected

      def description
        "contain script #{expected}"
      end

      def matches?(actual)
        @actual = actual
        canonize_js(actual.to_s).include?(canonize_js(expected))
      end

      def canonize_js(js)
        js = js.dup

        js.gsub! %r|//\s+<!\[CDATA\[[\n\r]+|, ''
        js.gsub! %r|[\n\r]+//\s+\]\]>|, ''

        js.gsub! /(\s*[\n\r]\s*)+/, ' '
        js.gsub! /^\s+|\s+$/, ''

        js
      end

      def failure_message_for_should
        <<-MSG.gsub(/^\s{10}/, '')
          expected that element of type #{@actual.class} contained script:
            expected: #{expected.is_a?(Regexp) ? '/' + canonize_js(expected.source) + '/' : canonize_js(expected)} (#{expected.class})
                 got: #{@actual.nil? ? 'nil' : canonize_js(@actual.to_s)}
        MSG
      end

      def failure_message_for_should_not
        <<-MSG.gsub(/^\s{10}/, '')
          expected that element of type #{actual.class} would not contain a script:
            script: #{expected.is_a?(Regexp) ? '/' + canonize_js(expected.source) + '/' : canonize_js(expected)} (#{expected.class})
        MSG
      end
    end

  end
end

RSpec::Matchers.module_eval do
  def contain_script(script)
    Arbre::RSpec::ContainScriptMatcher.new(script)
  end
end