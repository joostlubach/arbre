require 'spec_helper'
include Arbre::Html

describe Attributes do

  let(:attributes) { Attributes.new }

  describe 'creation' do

    it "should be able to be created using Attributes.new without arguments" do
      attributes = Attributes.new
      expect(attributes).to eq({})
    end

    it "should be able to be created using Attributes.new with a hash of arguments" do
      attributes = Attributes.new(:one => '1')
      expect(attributes).to eq({ 'one' => '1' })
    end

    it "should be able to be created using Attributes[] just like Hash[]" do
      expect(Hash).to receive(:[]).with(:one, '1').and_return(:one => '1')
      attributes = Attributes[:one, '1']
      expect(attributes).to eq({ 'one' => '1' })
    end

  end

  describe 'attribute accessing' do

    it "should support indifferent access" do
      attributes['one'] = 1
      attributes[:two] = 2
      attributes[3] = 3

      expect(attributes['one']).to eql('1')
      expect(attributes[:one]).to eql('1')
      expect(attributes['two']).to eql('2')
      expect(attributes[:two]).to eql('2')
      expect(attributes[3]).to eql('3')
      expect(attributes['3']).to eql('3')
      expect(attributes[:'3']).to eql('3')
    end

    it "should store an attribute as a string key and value" do
      attributes['one'] = 1
      attributes[:two] = 2
      attributes[3] = 3

      expect(attributes).to eq({ 'one' => '1', 'two' => '2', '3' => '3' })
    end

    it "should store a 'true' value as the name of the attribute itself" do
      attributes[:checked] = true
      expect(attributes).to eq({ 'checked' => 'checked' })
    end

    it "should store any value as its string version" do
      attributes[:number] = 5
      expect(attributes).to eq({ 'number' => '5' })
    end

    it "should remove an attribute that is set to false" do
      attributes = Attributes.new('one' => '1')
      attributes[:one] = false

      expect(attributes).to be_empty
    end

    it "should remove an attribute that is set to nil" do
      attributes = Attributes.new('one' => '1')
      attributes[:one] = nil

      expect(attributes).to be_empty
    end

  end

  describe "class attribute" do

    it "should return a ClassList when the class attribute is accessed" do
      expect(attributes[:class]).to be_a(ClassList)
      expect(attributes[:class]).to be_empty
      expect(attributes['class']).to be_a(ClassList)
      expect(attributes['class']).to be_empty
    end

    it "should wrap things into a class list when the attribute is set" do
      attributes[:class] = 'one'
      expect(attributes[:class].to_s).to eql('one')

      attributes[:class] = 'one two'
      expect(attributes[:class].to_s).to eql('one two')

      attributes[:class] = %[one two]
      expect(attributes[:class].to_s).to eql('one two')
      attributes[:class] << 'three four'
      expect(attributes[:class].to_s).to eql('one two three four')
    end

    it "should not set the attribute if a nil or empty array is passed" do
      attributes[:class] = nil
      expect(attributes).not_to have_key(:class)
      attributes[:class] = []
      expect(attributes).not_to have_key(:class)
    end

  end

  describe "style attribute" do

    it "should return a StyleHash when the class attribute is accessed" do
      expect(attributes[:style]).to be_a(StyleHash)
      expect(attributes[:style]).to be_empty
      expect(attributes['style']).to be_a(StyleHash)
      expect(attributes['style']).to be_empty
    end

    it "should wrap things into a style when the attribute is set" do
      attributes[:style] = 'one: two;'
      expect(attributes[:style]).to eql(StyleHash.new('one: two;'))

      attributes[:style] = {'one' => 'two'}
      expect(attributes[:style]).to eql(StyleHash.new('one' => 'two'))
    end

    it "should not set the attribute if a nil or empty hash is passed" do
      attributes[:style] = nil
      expect(attributes).not_to have_key(:style)
      attributes[:style] = []
      expect(attributes).not_to have_key(:style)
    end

  end

  describe '#remove' do

    it "should remove the attribute with the given name" do
      attributes = Attributes.new(:one => '1')
      attributes.remove 'one'
      expect(attributes).to be_empty
    end

    it "should remove the attribute with the given name (access indifferent)" do
      attributes = Attributes.new(:one => '1')
      attributes.remove :one
      expect(attributes).to be_empty
    end

  end

  describe '#update' do

    it "should update the attributes hash with new attributes" do
      attributes = Attributes.new(:one => '1', :two => '2')

      attributes.update 'one' => '2', :three => '3'
      expect(attributes).to eq('one' => '2', 'two' => '2', 'three' => '3')
    end

    it "should be able to remove attributes by updating them to nil" do
      attributes = Attributes.new(:one => '1', :two => '2')

      attributes.update 'one' => '2', :two => nil, :three => '3'
      expect(attributes).to eq('one' => '2', 'three' => '3')
    end

  end

  describe 'equality' do

    it "should be equal to any other hash-like construct with the same values" do
      expect(Attributes.new(:one => '1')).to eq(Attributes.new(:one => '1'))
      expect(Attributes.new(:one => '1')).to eq('one' => '1')
    end

    it "should be eql? only to other attribute hashes with the same values" do
      expect(Attributes.new(:one => '1')).to eql(Attributes.new(:one => '1'))
      expect(Attributes.new(:one => '1')).not_to eql('one' => '1')
    end

  end

  describe 'enumeration' do

    specify { expect(Attributes).to include(Enumerable) }

    it "should enumerate through all attributes using #each" do
      attributes = Attributes.new(:one => '1', :two => '2')

      result = []
      attributes.each { |k, v| result << [ k, v] }
      expect(result).to eql([ ['one', '1'], ['two', '2'] ])
    end

  end

  describe '#length, #size and #count' do

    it "should all report the number of the attributes" do
      expect(Attributes.new(:one => '2').length).to eql(1)
      expect(Attributes.new(:one => '2').size).to eql(1)
      expect(Attributes.new(:one => '2').count).to eql(1)
    end

  end

  describe '#empty?' do

    it "should be true if the attribute hash is empty" do
      expect(Attributes.new).to be_empty
    end

    it "should be false if the attributes array contains elements" do
      expect(Attributes.new(:one => '2')).not_to be_empty
    end

  end

  describe '#to_s' do

    it "should create a format suitable for in HTML tags" do
      attributes = Attributes.new(:href => 'http://www.google.com', :target => :_blank)
      expect(attributes.to_s).to eql('href="http://www.google.com" target="_blank"')
    end

    it "should escape any HTML entities" do
      attributes = Attributes.new(:dangerous => '<>"')
      expect(attributes.to_s).to eql('dangerous="&lt;&gt;&quot;"')
    end

    it "should be HTML safe" do
      attributes = Attributes.new(:dangerous => '<>"')
      expect(attributes.to_s).to be_html_safe
    end

    it "should not render an empty class attribute" do
      attributes = Attributes.new(:class => 'test')
      expect(attributes.to_s).to eql('class="test"')
      attributes[:class] = nil
      expect(attributes.to_s).to eql('')
    end

  end

end