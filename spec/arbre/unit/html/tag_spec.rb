require 'spec_helper'
include Arbre::Html

describe Tag do

  let(:tag) { Arbre::Html::Tag.new }

  ######
  # Building

    it "should use the first argument as content if it is given" do
      tag.build "Content"
      expect(tag.content).to eql('Content')
    end

    it "should accept attributes" do
      tag.build 'id' => 'my-tag'
      expect(tag.content).to eql('')
      expect(tag.id).to eql('my-tag')
    end

    it "should accept content and attributes" do
      tag.build "Content", 'id' => 'my-tag'
      expect(tag.content).to eql('Content')
      expect(tag.id).to eql('my-tag')
    end

    it "should accept symbolic keyword arguments as attributes as well" do
      tag.build "Content", 'id' => 'my-tag', :class => 'custom'
      expect(tag.content).to eql('Content')
      expect(tag.id).to eql('my-tag')
      expect(tag.classes.to_a).to eql(['custom'])
    end

  ######
  # Attributes

    specify { expect(tag.attributes).to be_a(Attributes) }

    it "should allow setting an attribute through #set_attribute" do
      tag.set_attribute :style, 'display: none;'
      tag.set_attribute 'placeholder', '(test)'
      expect(tag.attributes).to eq('style' => 'display: none;', 'placeholder' => '(test)')
    end

    it "should allow getting an attribute through #get_attribute" do
      tag.set_attribute :style, 'display: none;'
      expect(tag.get_attribute(:style)).to eql('display: none;')
      expect(tag.get_attribute('style')).to eql('display: none;')
    end

    it "should allow setting an attribute through an indexer" do
      tag[:style] = 'display: none;'
      tag['placeholder'] = '(test)'
      expect(tag.attributes).to eq('style' => 'display: none;', 'placeholder' => '(test)')
    end

    it "should allow getting an attribute through an indexer" do
      tag[:style] = 'display: none;'
      expect(tag[:style]).to eql('display: none;')
      expect(tag['style']).to eql('display: none;')
    end

    it "should check whether an attribute is set through has_attribute?" do
      tag[:style] = 'display: none;'
      expect(tag).to have_attribute(:style)
      expect(tag).to have_attribute('style')
      expect(tag).not_to have_attribute(:placeholder)
    end

    describe "attribute accessors" do

      let(:tag_class) do
        Class.new(Input) do
          attribute :value
          attribute :autocomplete, boolean: true
        end
      end
      let(:tag) { tag_class.new }

      it "should allow access to the :value attribute through a method" do
        tag.value = 'Test'
        expect(tag[:value]).to eql('Test')
        tag[:value] = 'Test'
        expect(tag.value).to eql('Test')
      end

      it "should allow access to the boolean attribute :autocomplete through a method" do
        tag.autocomplete = true
        expect(tag.autocomplete).to be_true
        expect(tag[:autocomplete]).to eql('autocomplete')

        tag.autocomplete = double(:something_trueish)
        expect(tag.autocomplete).to be_true
        expect(tag[:autocomplete]).to eql('autocomplete')

        tag.autocomplete = false
        expect(tag.autocomplete).to be_false
        expect(tag[:autocomplete]).to be_nil
      end

    end

  ######
  # ID & classes

    describe '#generate_id' do
      it "should generate an ID for the tag using its object_id" do
        tag.generate_id!
        expect(tag.id).to eql(tag.object_id.to_s)
        expect(tag[:id]).to eql(tag.object_id.to_s)
      end
    end

    describe '#classes' do
      it "should be the same as the :class attribute" do
        expect(tag.classes).to be(tag[:class])
      end
    end

    describe '#classes=' do
      it "should replace the class attribute" do
        expect(tag.attributes).to receive(:[]=).with(:class, 'one')
        tag.classes = 'one'
      end
    end

    describe '#add_class' do
      it "should add classes" do
        tag.add_class 'one'
        expect(tag.classes.to_a).to eql(['one'])
        tag.add_class 'two three'
        expect(tag.classes.to_a).to eql(['one', 'two', 'three'])
      end
    end

    describe '#remove_class' do
      it "should remove classes" do
        tag.classes = 'one two three'
        expect(tag.classes.to_a).to eql(['one', 'two', 'three'])
        tag.remove_class 'two three'
        expect(tag.classes.to_a).to eql(['one'])
      end
    end

    describe '#has_class?' do
      it "should check whether the given class is present" do
        tag.classes = 'one two three'
        expect(tag).to have_class('one')
        expect(tag).not_to have_class('four')
      end

      it "should check whether *all* given classes is present" do
        tag.classes = 'one two three'
        expect(tag).to have_class('one two')
        expect(tag).not_to have_class('two four')
      end
    end

  ## Rendering is exemplified in the integration HTML spec.

end
