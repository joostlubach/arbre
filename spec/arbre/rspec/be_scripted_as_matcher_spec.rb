require 'spec_helper'

describe Arbre::RSpec::BeScriptedAsMatcher do

  it "should fail if the actual's content was not the same" do
    expect{ expect(double(:content => 'alert("test");')).to be_scripted_as('alert("something else");') }
      .to raise_error(RSpec::Expectations::ExpectationNotMetError, <<-STR.gsub(/^\s{8}/, ''))
        expected that element of type RSpec::Mocks::Mock would be scripted differently:
          expected: alert("something else"); (String)
               got: alert("test");
    STR
  end

  it "should fail if the actual's content did not match the regular expression" do
    expect{ expect(double(:content => 'alert("test");')).to be_scripted_as(/regular* expression{1,2}/) }
      .to raise_error(RSpec::Expectations::ExpectationNotMetError, <<-STR.gsub(/^\s{8}/, ''))
        expected that element of type RSpec::Mocks::Mock would be scripted differently:
          expected: /regular* expression{1,2}/ (Regexp)
               got: alert("test");
    STR
  end

  it "should pass if the actual's content did match the given string" do
    expect{ expect(double(:content => 'alert("test");')).to be_scripted_as('alert("test");') }
      .not_to raise_error
  end

  it "should pass if the actual's content did match the given regular expression" do
    expect{ expect(double(:content => 'alert("test");')).to be_scripted_as(/alert\("\w+"\);/) }
      .not_to raise_error
  end

  it "should pass if the actual's content did match the given string, where whitespace is ignored" do
    expect{ expect(double(:content => '  alert("test");  ')).to be_scripted_as('alert("test");') }
      .not_to raise_error
    expect{ expect(double(:content => "alert(\"test\");\n")).to be_scripted_as('  alert("test");  ') }
      .not_to raise_error
  end

  it "should fail if the whitespace difference was significant" do
    expect{ expect(double(:content => 'alert("test   " );')).to be_scripted_as('alert("test");') }
      .to raise_error(RSpec::Expectations::ExpectationNotMetError, <<-STR.gsub(/^\s{8}/, ''))
        expected that element of type RSpec::Mocks::Mock would be scripted differently:
          expected: alert("test"); (String)
               got: alert("test   " );
    STR
  end

  it "should pass if the actual's content did match the given regular expression, where whitespace is ignored" do
    expect{ expect(double(:content => '  alert("test");  ')).to be_scripted_as(/alert\("\w+"\);/) }
      .not_to raise_error
    expect{ expect(double(:content => "alert(\"test\");\n")).to be_scripted_as(/  alert\("\w+"\);  /) }
      .not_to raise_error
  end

  it "should pass if the actual's content matched the given string, where placeholders were used" do
    expect{ expect(double(:content => 'var a=1; alert("test");')).to be_scripted_as('(...)alert("test");') }
      .not_to raise_error
  end

end