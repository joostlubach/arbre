require 'spec_helper'
include Arbre::Html

describe ClassList do

  describe "ClassList method" do
    it "should call ClassList.from_string" do
      list = double()
      expect(ClassList).to receive(:from_string).with('first second').and_return(list)
      expect(ClassList('first second')).to be(list)
    end
  end

  describe ".from_string" do
    it "should build a new list from a string of classes" do
      list = ClassList.from_string("first second")

      expect(list).to have(2).classes
      expect(list.to_a).to match_array(%w[first second])
    end
  end

  describe "#add" do

    it "should add one class" do
      list = ClassList('one')

      list << 'two' << 'three'
      list.add 'four'

      expect(list.to_a).to match_array(%w[one two three four])
    end

    it "should add multiple classes in one string" do
      list = ClassList('one')
      list << 'two three'
      list.add 'four five'
      expect(list.to_a).to match_array(%w[one two three four five])
    end

  end

  describe "#to_s" do

    it "should output html-ready content" do
      list = ClassList('one two three')
      list << 'four'
      expect(list.to_s).to eql('one two three four')
    end

  end

end
