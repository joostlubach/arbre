require 'spec_helper'

describe Arbre::RSpec::BeRenderedAsMatcher do

  it "should fail if the actual was nil" do
    expect{ expect(nil).to be_rendered_as('<html/>') }
      .to raise_error(RSpec::Expectations::ExpectationNotMetError, <<-STR.gsub(/^\s{8}/, ''))
        expected that element of type NilClass would be rendered differently:
          expected: <html/> (String)
               got: nil
    STR
  end

  it "should fail if the actual's string version was not the same" do
    expect{ expect(double(:to_s => '<html></html>'.html_safe)).to be_rendered_as('<html/>') }
      .to raise_error(RSpec::Expectations::ExpectationNotMetError, <<-STR.gsub(/^\s{8}/, ''))
        expected that element of type RSpec::Mocks::Double would be rendered differently:
          expected: <html/> (String)
               got: <html></html>
    STR
  end

  it "should fail if the actual's string version did not match the regular expression" do
    expect{ expect(double(:to_s => '<html></html>'.html_safe)).to be_rendered_as(/regular* expression{1,2}/) }
      .to raise_error(RSpec::Expectations::ExpectationNotMetError, <<-STR.gsub(/^\s{8}/, ''))
        expected that element of type RSpec::Mocks::Double would be rendered differently:
          expected: /regular* expression{1,2}/ (Regexp)
               got: <html></html>
    STR
  end

  it "should fail if the actual's string was not HTML-safed" do
    expect{ expect(double(:to_s => '<html></html>')).to be_rendered_as('<html></html>') }
      .to raise_error(RSpec::Expectations::ExpectationNotMetError, <<-STR.gsub(/^\s{8}/, ''))
        expected that element of type RSpec::Mocks::Double would be rendered differently:
          expected: <html></html> (String)
               got: &lt;html&gt;&lt;/html&gt;
    STR
  end

  it "should pass if the actual's string version did match the given string" do
    expect{ expect('<html></html>'.html_safe).to be_rendered_as('<html></html>') }
      .not_to raise_error
  end

  it "should pass if the actual's string version did match the given regular expression" do
    expect{ expect('<html></html>'.html_safe).to be_rendered_as(/<html>.*?<\/html>/) }
      .not_to raise_error
  end

  it "should pass if the actual's string version did match the given string, where whitespace is ignored" do
    expect{ expect('<html>  </html>'.html_safe).to be_rendered_as('<html></html>') }
      .not_to raise_error
    expect{ expect("<html>\n</html>\n".html_safe).to be_rendered_as('<html>  </html>') }
      .not_to raise_error
  end

  it "should pass if the actual's string version did match the given regular expression, where whitespace is ignored" do
    expect{ expect('<html>  </html>'.html_safe).to be_rendered_as(/<html>.*?<\/html>/) }
      .not_to raise_error
    expect{ expect("<html>\n</html>\n".html_safe).to be_rendered_as(/<html.*>  <\/html>/) }
      .not_to raise_error
  end

  it "should pass if the actual's string version did match the given string, where attribute order is ignored" do
    expect{ expect('<html lang="en" data-something="two"></html>'.html_safe).to be_rendered_as('<html data-something="two" lang="en"></html>') }
      .not_to raise_error
  end

  it "should pass if the actual's string version did match the given regex, where attribute order is ignored" do
    expect{ expect('<html lang="en" data-something="two"></html>'.html_safe).to be_rendered_as(/<html data-something="two" lang="en">.*<\/html>/) }
      .not_to raise_error
  end

  it "should pass if the actual's string version matched the given string, where placeholders were used" do
    expect{ expect('<html><body></body></html>'.html_safe).to be_rendered_as('<html>(...)</html>') }
      .not_to raise_error
  end

end