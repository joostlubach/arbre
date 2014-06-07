require 'spec_helper'
include Arbre

describe ElementCollection do

  ######
  # Collection stuff

    let(:element1) { Element.new }
    let(:element2) { Element.new }
    let(:element3) { Element.new }

    it "should initialize as an empty collection by default" do
      elements = ElementCollection.new
      expect(elements).to be_empty
    end

    it "should behave like an array" do
      elements = ElementCollection.new([element1])
      expect(elements).to match([element1])

      elements << element2
      expect(elements).to match([element1, element2])

      elements = ElementCollection.new
      elements.concat [ element1, element2 ]
      expect(elements).to match([element1, element2])

      elements.clear
      expect(elements).to be_empty
    end

    it "should wrap any enumerable indexing result in another element collection" do
      collection = ElementCollection.new([element1, element2, element3])

      expect(collection[0]).to be_a(Element)

      expect(collection[0..1]).to be_a(ElementCollection)
      expect(collection[0..1]).to match([element1, element2])

      expect(collection[0, 1]).to be_a(ElementCollection)
      expect(collection[0, 1]).to match([element1])
    end

    it "should equate to an array" do
      expect(ElementCollection.new([element1, element2])).to eq([element1, element2])
      expect(ElementCollection.new([element1, element2])).not_to eq([element2, element1])
      expect(ElementCollection.new([element1, element2])).not_to eq([element1])
    end

    it "should equate to another collection with the same elements" do
      collection = ElementCollection.new([element1, element2])
      expect(collection).to eq(ElementCollection.new([element1, element2]))
      expect(collection).not_to eq(ElementCollection.new([element2, element1]))
      expect(collection).not_to eq(ElementCollection.new([element1]))
    end

    it "should not be eql? an array" do
      expect(ElementCollection.new([element1, element2])).not_to eql([element1, element2])
    end

    it "should be eql? to another collection with the same elements" do
      collection = ElementCollection.new([element1, element2])
      expect(collection).to eq(ElementCollection.new([element1, element2]))
      expect(collection).not_to eq(ElementCollection.new([element2, element1]))
      expect(collection).not_to eq(ElementCollection.new([element1]))
    end

    it "should rename 'delete' to 'remove'" do
      elements = ElementCollection.new([element1, element2])
      elements.remove element2
      expect(elements).to eq([element1])
    end

    describe '#+' do

      it "should combine itself with another collection" do
        collection1 = ElementCollection.new([element1, element2])
        collection2 = ElementCollection.new([element2, element3])
        expect(collection1 + collection2).to be_a(ElementCollection)
        expect(collection1 + collection2).to eq([element1, element2, element3])
      end

      it "should combine itself with an array" do
        collection = ElementCollection.new([element1, element2])
        expect(collection + [element2, element3]).to be_a(ElementCollection)
        expect(collection + [element2, element3]).to eq([element1, element2, element3])
      end

    end

    describe '#-' do

      it "should subtract another collection from itself" do
        collection1 = ElementCollection.new([element1, element2])
        collection2 = ElementCollection.new([element2, element3])
        expect(collection1 - collection2).to be_a(ElementCollection)
        expect(collection1 - collection2).to eq([element1])
      end

      it "should combine itself with an array" do
        collection = ElementCollection.new([element1, element2])
        expect(collection - [element2, element3]).to be_a(ElementCollection)
        expect(collection - [element2, element3]).to eq([element1])
      end

    end

    describe '#&' do

      it "should intersect itself with another collection" do
        collection1 = ElementCollection.new([element1, element2])
        collection2 = ElementCollection.new([element2, element3])
        expect(collection1 & collection2).to be_a(ElementCollection)
        expect(collection1 & collection2).to eq([element2])
      end

      it "should intersect itself with an array" do
        collection = ElementCollection.new([element1, element2])
        expect(collection & [element2, element3]).to be_a(ElementCollection)
        expect(collection & [element2, element3]).to eq([element2])
      end

    end

    it "should not add the same element more than once" do
      collection = ElementCollection.new
      element = Element.new
      collection << element << element
      expect(collection.size).to eql(1)
    end

    specify "#to_a should create a copy of the elements and #to_ary not" do
      collection = ElementCollection.new([element1, element2])
      expect(collection.to_ary).to be(collection.to_ary)
      expect(collection.to_a).not_to be(collection.to_a)
      expect(collection.to_a).to eql(collection.to_a)
    end

  ######
  # Rendering

    describe '#to_s' do

      let(:collection) { ElementCollection.new([element1, element2]) }

      it "should join all elements' to_s result with a return" do
        expect(element1).to receive(:to_s).and_return('(ELEMENT1)')
        expect(element2).to receive(:to_s).and_return('(ELEMENT2)')
        expect(collection.to_s).to eql("(ELEMENT1)\n(ELEMENT2)")
      end

      it "should be HTML-safe" do
        expect(element1).to receive(:to_s).and_return('<span>')
        expect(element2).to receive(:to_s).and_return('<span>'.html_safe)
        expect(collection.to_s).to eql("&lt;span&gt;\n<span>")
      end

    end

end