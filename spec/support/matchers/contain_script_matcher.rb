# Used to match JS snippets in HTML content. The JS is canonized as much as possible, so that you don't have to
# worry about whitespace. Use '(...)' as a wildcard. You may even place text in the wildcard for
# readability: '(... some wildcard ...)'.
#
# == Examples
#
#   expect(document.body).to contain_script('Flux.Application.initialize()')
#   expect(document.body).to contain_script('Flux.Application.initialize((... args ...))')
RSpec::Matchers.define :contain_script do |expected|
  match do |actual|
    regexp = case expected
    when Regexp then Regexp.new(canonize_js(expected.source))
    else Regexp.new(Regexp.escape(canonize_js(expected)).gsub(/\\\(\\\.\\\.\\\..*?(?:\\\.\\\.\\\.)?\\\)/, '.+'))
    end

    canonize_js(actual.to_s) =~ regexp
  end

  def canonize_js(js)
    js = js.dup

    js.gsub! %r|//\s+<!\[CDATA\[[\n\r]+|, ''
    js.gsub! %r|[\n\r]+//\s+\]\]>|, ''

    js.gsub! /(\s*[\n\r]\s*)+/, ' '
    js.gsub! /^\s+|\s+$/, ''

    js
  end

  failure_message_for_should do |actual|
    <<-MSG.gsub(/^\s{6}/, '')
      expected that element of type #{actual.class} contained script:
        expected: #{expected.is_a?(Regexp) ? '/' + canonize_js(expected.source) + '/' : canonize_js(expected)} (#{expected.class})
             got: #{actual.nil? ? 'nil' : canonize_js(actual.to_s)}
    MSG
  end

  failure_message_for_should_not do |actual|
    <<-MSG.gsub(/^\s{6}/, '')
      expected that element of type #{actual.class} would not contain a script:
        script: #{expected.is_a?(Regexp) ? '/' + canonize_js(expected.source) + '/' : canonize_js(expected)} (#{expected.class})
    MSG
  end

  description do
    "contain script #{expected}"
  end
end

RSpec::Matchers.define :be_scripted_as do |expected|
  match do |actual|
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

  failure_message_for_should do |actual|
    <<-MSG.gsub(/^\s{6}/, '')
      expected that element of type #{actual.class} would be scripted differently:
        expected: #{expected.is_a?(Regexp) ? '/' + canonize_js(expected.source) + '/' : canonize_js(expected)} (#{expected.class})
             got: #{actual.nil? ? 'nil' : canonize_js(actual.content)}
    MSG
  end

  failure_message_for_should_not do |actual|
    "expected that element of type #{actual.class} would be not scripted as #{expected}"
  end

  description do
    "be scripted as #{expected}"
  end
end