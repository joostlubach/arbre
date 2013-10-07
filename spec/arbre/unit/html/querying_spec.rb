require 'spec_helper'
include Arbre
include Arbre::Html

describe Querying do

  describe '#find and #find_first' do
    it "should use a Query object" do
      element = Element.new
      fieldset = Element.new

      query = double()
      allow(Query).to receive(:new).with(element).and_return(query)
      allow(query).to receive(:execute).with('fieldset#username').and_return([fieldset])
      expect(element.find('fieldset#username')).to eql([fieldset])
      expect(element.find_first('fieldset#username')).to be(fieldset)
    end

    it "should fail gracefully" do
      element = Element.new
      query = double()

      allow(Query).to receive(:new).with(element).and_return(query)
      allow(query).to receive(:execute).with('fieldset#username').and_return([])
      expect(element.find('fieldset#username')).to eql([])
      expect(element.find_first('fieldset#username')).to be_nil
    end
  end

  # Other methods are integration-specced.

end
