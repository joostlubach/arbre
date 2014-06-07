module Arbre
  module RSpec

    # Used to match JS snippets in HTML content. The JS is canonized as much as possible, so that you don't have to
    # worry about whitespace. Use '(...)' as a wildcard. You may even place text in the wildcard for
    # readability: '(... some wildcard ...)'.
    #
    # == Examples
    #
    #   expect(document.body.find_first('javascript')).to be_scripted_as('Flux.Application.initialize()')
    #   expect(document.body.find_first('javascript')).to be_scripted_as('Flux.Application.initialize((... args ...))')
    class BeScriptedAsMatcher

      def initialize(expected)
        @expected = expected
      end

      attr_reader :expected

      def description
        "be scripted as #{expected}"
      end

      def matches?(actual)
        @actual = actual

        regexp = case expected
        when Regexp then Regexp.new(canonize_js(expected.source))
        else Regexp.new('^' + Regexp.escape(canonize_js(expected)).gsub('\(\.\.\.\)', '.+') + '$')
        end

        canonize_js(actual.content) =~ regexp
      end

      def canonize_js(js)
        js = js.dup

        js.gsub! %r|//\s+<!\[CDATA\[[\n\r]+|, ''
        js.gsub! %r|[\n\r]+//\s+\]\]>|, ''

        js.gsub! /(\s*[\n\r]\s*)+/, ' '
        js.gsub! /^\s+|\s+$/, ''

        js
      end

      def failure_message
        <<-MSG.gsub(/^\s{10}/, '')
          expected that element of type #{@actual.class} would be scripted differently:
            expected: #{expected.is_a?(Regexp) ? '/' + canonize_js(expected.source) + '/' : canonize_js(expected)} (#{expected.class})
                 got: #{@actual.nil? ? 'nil' : canonize_js(@actual.content)}
        MSG
      end

      def failure_message_when_negated
        "expected that element of type #{@actual.class} would be not scripted as #{expected}"
      end

    end

  end
end

RSpec::Matchers.module_eval do
  def be_scripted_as(script)
    Arbre::RSpec::BeScriptedAsMatcher.new(script)
  end
end