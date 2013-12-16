require 'spec_helper'

describe Arbre::RSpec::ContainScriptMatcher do

  it "should fail if the actual's content did not contain the given script" do
    expect{ expect(double(:to_s => '<script type="javascript">alert("test");</script>')).to contain_script('alert("something else");') }
      .to raise_error(RSpec::Expectations::ExpectationNotMetError, <<-STR.gsub(/^\s{8}/, ''))
        expected that element of type RSpec::Mocks::Mock contained script:
          expected: alert("something else"); (String)
               got: <script type="javascript">alert("test");</script>
    STR
  end

  it "should pass if the actual's content did match the given string" do
    expect{ expect(double(:to_s => '<script type="javascript">alert("test");</script>')).to contain_script('alert("test");') }
      .not_to raise_error
  end

  it "should pass if the actual's content contained given string" do
    expect{ expect(double(:to_s => '<body><script type="javascript">var a = 1; alert("test");</script></body>')).to contain_script('alert("test");') }
      .not_to raise_error
  end

  it "should pass if the actual's content did match the given string, where whitespace is ignored" do
    expect{ expect(double(:to_s => '<script type="javascript">  alert("test");  </script>')).to contain_script('alert("test");') }
      .not_to raise_error
    expect{ expect(double(:to_s => "<script type=\"javascript\">alert(\"test\");\n</script>")).to contain_script('  alert("test");  ') }
      .not_to raise_error
  end

  it "should fail if the whitespace difference was significant" do
    expect{ expect(double(:to_s => '<script type="javascript">alert("test   " );</script>')).to contain_script('alert("test");') }
      .to raise_error(RSpec::Expectations::ExpectationNotMetError, <<-STR.gsub(/^\s{8}/, ''))
        expected that element of type RSpec::Mocks::Mock contained script:
          expected: alert("test"); (String)
               got: <script type="javascript">alert("test   " );</script>
    STR
  end

end