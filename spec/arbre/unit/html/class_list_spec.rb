require 'spec_helper'
include Arbre::Html

describe ClassList do

  describe "initializer" do
    it "should be able to be initialized without arguments" do
      list = ClassList.new
      expect(list).to be_empty
    end

    it "should be able to be initialized with an array of classes" do
      list = ClassList.new(['one', 'two'])
      expect(list.to_a).to eql(['one', 'two'])
    end

    it "should be able to be initialized with a string containing one class" do
      list = ClassList.new('one')
      expect(list.to_a).to eql(['one'])
    end

    it "should be able to be initialized with a string containing multiple classes separated by a space" do
      list = ClassList.new('one two')
      expect(list.to_a).to eql(['one', 'two'])
    end
  end

  describe '#classes' do
    it "should be an alias to itself" do
      list = ClassList.new('one two')
      expect(list.classes).to be(list)
    end
  end

  describe "#add" do

    it "should add one class" do
      list = ClassList.new('one')

      list << 'two' << 'three'
      list.add 'four'

      expect(list.to_a).to match_array(%w[one two three four])
    end

    it "should add multiple classes in one string" do
      list = ClassList.new('one')
      list << 'two three'
      list.add 'four five'
      expect(list.to_a).to match_array(%w[one two three four five])
    end

    it "should add a class using a symbol" do
      list = ClassList.new('one')
      list << :two
      expect(list.to_a).to match_array(%w[one two])
    end

  end

  describe '#concat' do

    it "should append all classes in the given array" do
      list = ClassList.new('one two')
      list.concat [ 'three', 'four five' ]
      expect(list.to_a).to match_array(%w[one two three four five])
    end

  end

  describe "#remove" do

    it "should remove one class" do
      list = ClassList.new('one two')
      list.remove 'one'
      expect(list.to_a).to eql(['two'])
    end

    it "should add multiple classes in one string" do
      list = ClassList.new('one two three')
      list.remove 'one three'
      expect(list.to_a).to eql(['two'])
    end

  end

  describe "equality" do

    it "should be equal to another ClassList with the same classes" do
      expect(ClassList.new('one two')).to eq(ClassList.new('two one'))
    end

    it "should be equal to an array with the same classes" do
      expect(ClassList.new('one two')).to eq(['two', 'one'])
    end

  end

  describe "#to_s" do

    it "should output html-ready content" do
      list = ClassList.new('one two three')
      list << 'four'
      expect(list.to_s).to eql('one two three four')
    end

  end

end
