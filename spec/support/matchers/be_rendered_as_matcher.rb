# Used to match HTML snippets. HTML is canonized as much as possible, so that you don't have to worry about
# whitespace or attribute order. Use '(...)' as a wildcard. You may even place text in the wildcard for
# readability: '(... some wildcard ...)'.
#
# == Examples
#
#   expect('<a href="test" target="_blank"/>').to \
#     be_rendered_as('<a target="_blank" href="test" />') # => true
#   expect('<div><span></span><sub></sub></div>').to \
#     be_rendered_as('<div>(...)</div>') # => true
#   expect('<div><span></span><sub></sub></div>').to \
#     be_rendered_as('<div>(... a span here ...)<sub></sub></div>') # => true
RSpec::Matchers.define :be_rendered_as do |expected|
  match do |actual|
    regexp = case expected
    when Regexp then Regexp.new(canonize_html(expected.source))
    else Regexp.new('^' + Regexp.escape(canonize_html(expected)).gsub(/\\\(\\\.\\\.\\\..*?(?:\\\.\\\.\\\.)?\\\)/, '.+') + '$')
    end

    canonize_html(actual.to_s) =~ regexp
  end

  def canonize_html(html)
    html = html.dup

    html.gsub! /(\s*[\n\r]\s*)+/, ' '
    html.gsub! /^\s+|\s+$/, ''
    html.gsub! /\s*(\/?>|<)\s*/, '\1'

    # Extract and order attributes.
    html.gsub! %r|(<[-_:\w].*?>)| do |all|
      all =~ %r|(<[-_:\w]+\s*)(.*?)(\s*/?>)|
      _, pre, attributes, post = $~.to_a

      has_wildcard = attributes =~ /\(\.\.\..*?(?:\.\.\.)?\)/ && attributes =~ /\w+/
      attributes = attributes.gsub(/\(\.\.\..*?(?:\.\.\.)?\)/, '') if has_wildcard
      attributes = attributes.scan(/(\(\.\.\..*?(?:\.\.\.)?\)|[-_:\w]+(?:=(?:".*?"|'.*?'|\S+))?)/).sort.join(' ')
      if has_wildcard
        attributes = "(...)#{attributes}(...)"
        pre.chomp! ' '
      end

      "#{pre}#{attributes}#{post}"
    end

    # Extract and order classes and styles
    html.gsub! %r[(class|style)="(.*?)"] do |all|
      all =~ %r[(class|style)="(.*?)"]

      attribute = $1
      items = $2.strip.split(/(;\s*|\s+)/).reject(&:blank?).sort.join(' ')
      %[#{attribute}="#{items}"]
    end

    html
  end

  failure_message_for_should do |actual|
    <<-MSG.gsub(/^\s{6}/, '')
      expected that element of type #{actual.class} would be rendered differently:
        expected: #{expected.is_a?(Regexp) ? '/' + canonize_html(expected.source) + '/' : canonize_html(expected)} (#{expected.class})
             got: #{actual.nil? ? 'nil' : canonize_html(actual.to_s)}
    MSG
  end

  failure_message_for_should_not do |actual|
    <<-MSG.gsub(/^\s{6}/, '')
      expected that element of type #{actual.class} would not be rendered as #{canonize_html(expected)}, but it was:
        got: #{actual.nil? ? 'nil' : canonize_html(actual.to_s)}
    MSG
  end

  description do
    "be rendered as #{expected}"
  end
end