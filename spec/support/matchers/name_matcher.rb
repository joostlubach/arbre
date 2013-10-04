# Used to match something with a name.
#
# == Usage
#
#   something = double(:name => 'My Name')
#   expect(something).to be_named('My Name')
#
# Note that the name should be a string, nothing is converted:
#
#   expect(double(:name => :my_name)).to be_named('my_name') # => fails
RSpec::Matchers.define :be_named do |expected|

  match do |actual|
    actual.respond_to?(:name) && actual.name == expected
  end

  failure_message_for_should do |actual|
    if actual.respond_to?(:name)
      if actual.name.nil?
        <<-MSG.gsub(/^\s{8}/, '')
          expected that #{actual} would be named '#{expected}', but it has no name
        MSG
      elsif actual.name.class != expected.class
        <<-MSG.gsub(/^\s{8}/, '')
          expected that #{actual} would be named '#{expected}', but its name is of class #{actual.name.class}
        MSG
      else
        <<-MSG.gsub(/^\s{8}/, '')
          expected that #{actual} would be named '#{expected}', but it was named '#{actual}'
            got:      '#{actual.name}'
            expected: '#{expected}'
        MSG
      end
    else
      <<-MSG.gsub(/^\s{8}/, '')
        expected that #{actual} would be named '#{expected}', but it doesn't respond to `name'
      MSG
    end
  end

  failure_message_for_should_not do |actual|
    <<-MSG.gsub(/^\s{6}/, '')
      expected that #{actual} would not be named '#{expected}', but it is
    MSG
  end

  description do
    "be named '#{expected}'"
  end
end