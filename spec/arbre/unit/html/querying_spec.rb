require 'spec_helper'
include Arbre
include Arbre::Html

describe Querying do

  describe '#find' do
    it "should use a Query object" do
      element = Element.new
      fieldset = Element.new

      query = double()
      expect(Query).to receive(:new).with(element).and_return(query)
      expect(query).to receive(:execute).with('fieldset#username').and_return(fieldset)
      expect(element.find('fieldset#username')).to eql(fieldset)
    end
  end

  describe '#descendant_tags' do
  end

  describe '#find_by_id' do
  end

  describe '#find_by_tag_or_classes' do
  end

end
