require 'spec_helper'
include Arbre

describe ChildElementCollection do

  specify { expect(ChildElementCollection).to be < ElementCollection }

  let(:parent) { Element.new }
  let(:collection) { ChildElementCollection.new(parent) }

  let(:element) { Element.new }
  let(:element1) { Element.new }
  let(:element2) { Element.new }
  let(:element3) { Element.new }

  ######
  # Parent

    it "should store its parent" do
      expect(collection.parent).to be(parent)
    end

    it "should only be eql? to another collection if the parent is the same" do
      collection1 = ChildElementCollection.new(parent)
      collection1 << element1

      collection2 = ChildElementCollection.new(parent)
      collection2 << element1
      expect(collection1).to eql(collection2)

      collection2 = ChildElementCollection.new(Element.new)
      collection2 << element1
      expect(collection1).not_to eql(collection2)
    end

    it "should set the parent to each child element that is added to the collection" do
      collection << element1
      expect(element1.parent).to be(parent)

      collection = ChildElementCollection.new(parent)
      collection.insert_at 0, element2
      expect(element2.parent).to be(parent)
    end

    it "should remove any element that is added to the collection from its existing parent" do
      expect(element1).to receive(:remove!)
      expect(element2).to receive(:remove!)

      collection << element1
      collection.insert_at 0, element2
    end

    it "should unset the parent from each child element that is removed from the collection" do
      collection << element
      collection.remove element
      expect(element.parent).to be_nil
    end

    it "should not add or set the parent of the same element twice" do
      expect(element).to receive(:parent=).once.with(parent)
      collection << element << element
      expect(collection).to have(1).item

      collection = ChildElementCollection.new(parent)
      expect(element).to receive(:parent=).once.with(parent)
      collection << element
      collection.insert_at 0, element
      expect(collection).to have(1).item
    end

    it "should not unset the parent if the given element was not part of the collection" do
      element.parent = Element.new
      collection.remove element
      expect(element.parent).not_to be_nil
    end

    it "should not the parents of all elements if #clear is used" do
      collection << element1 << element2

      expect(element1.parent).not_to be_nil
      expect(element2.parent).not_to be_nil
      collection.clear
      expect(element1.parent).to be_nil
      expect(element2.parent).to be_nil
    end

  ######
  # Inserting

    describe '#insert_at' do
      it "should insert the element at the given index" do
        collection << element1 << element3
        collection.insert_at 1, element2

        expect(collection).to eq([element1, element2, element3])
      end

      it "should move, and not duplicate, an element that already existed in the collection" do
        collection << element1 << element3 << element2
        collection.insert_at 1, element2
        expect(collection).to eq([element1, element2, element3])
      end

      it "should be able to move an element towards the back" do
        collection << element2 << element1 << element3
        collection.insert_at 2, element2
        expect(collection).to eq([element1, element2, element3])
      end

    end

    describe '#insert_after' do
      it "should insert the element after the other element" do
        collection << element1
        collection.insert_after element1, element3
        collection.insert_after element1, element2

        expect(collection).to eq([element1, element2, element3])
      end

      it "should raise an error if the given reference element did not exist in the collection" do
        collection << element1
        expect(element2).to receive(:to_s).and_return('element2')
        expect { collection.insert_after element2, element3 }.to \
          raise_error(ArgumentError, 'existing element element2 not found')
      end
    end

    describe '#insert_before' do
      it "should insert the element after the other element" do
        collection << element3
        collection.insert_before element3, element1
        collection.insert_before element3, element2

        expect(collection).to eq([element1, element2, element3])
      end

      it "should raise an error if the given reference element did not exist in the collection" do
        collection << element1
        expect(element2).to receive(:to_s).and_return('element2')
        expect { collection.insert_before element2, element3 }.to \
          raise_error(ArgumentError, 'existing element element2 not found')
      end
    end

end
