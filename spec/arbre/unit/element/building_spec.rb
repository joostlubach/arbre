require 'spec_helper'
include Arbre

describe Element::Building do

  # Note - builder methods are specced in integration/element_building_spec.rb.

  let(:element_class) { Class.new(Element) }
  let(:element) { element_class.new(arbre) }

  ######
  # Build & insert element

    describe '#build_element' do

      it "should create an element from the given class and build it using the given arguments and block" do
        block = proc {}

        expect(element_class).to receive(:new).with(arbre).and_return(element)
        expect(element).to receive(:build).with(:arg1, :arg2) do |&blk|
          expect(blk).to be(block)
          expect(element.current_element).to be(element)
        end

        result = arbre.build_element(element_class, :arg1, :arg2, &block)
        expect(result).to be(element)
      end

    end

    describe '#insert_element' do

      it "should create an element from the given class, insert it, and build it using the given arguments and block" do
        block = proc {}
        parent = Element.new

        expect(element_class).to receive(:new).with(arbre).and_return(element)
        expect(element).to receive(:build).with(:arg1, :arg2) do |&blk|
          # Note: the parent should be known when the build method is called!
          expect(element.parent).to be(parent)
          expect(blk).to be(block)
          expect(element.current_element).to be(element)
        end

        result = arbre.within(parent) { arbre.insert_element(element_class, :arg1, :arg2, &block) }
        expect(result).to be(element)
        expect(parent.children).to eq([element])
      end

    end

  ######
  # Within

    describe '#within' do
      it "should call within_element on to arbre_context" do
        block = proc{}
        element = Element.new
        expect(arbre).to receive(:within_element).with(element) do |&blk|
          expect(blk).to be(block)
        end

        Element.new(arbre).instance_exec do
          within element, &block
        end
      end

      it "should resolve any string into an element using 'find'" do
        block = proc{}
        element = Element.new
        expect(arbre).to receive(:within_element).with(element)

        context_element = Element.new(arbre)
        expect(context_element).to receive(:find).with('fieldset#username').and_return([element])
        context_element.instance_exec do
          within 'fieldset#username', &block
        end
      end
    end

    describe '#prepend_within' do
      it "should call within and with_flow(:prepend) on the context" do
        block = proc {}
        element = Element.new
        expect(arbre).to receive(:within).with(element) do |&blk|
          blk.call
        end
        expect(arbre).to receive(:with_flow).with(:prepend) do |&blk|
          expect(blk).to be(block)
        end

        Element.new(arbre).instance_exec do
          prepend_within element, &block
        end
      end

      it "should resolve any string into an element using 'find'" do
        block = proc{}
        element = Element.new
        expect(arbre).to receive(:within).with(element)

        context_element = Element.new(arbre)
        expect(context_element).to receive(:find).with('fieldset#username').and_return([element])
        context_element.instance_exec do
          prepend_within 'fieldset#username', &block
        end
      end
    end

  ######
  # Append / prepend

    describe '#append' do

      it "should insert an element of the given class using the :append flow" do
        block = proc {}
        expect(arbre).to receive(:insert_element).with(element_class, :one, :two) do |&blk|
          expect(blk).to be(block)
          expect(arbre.current_flow).to be(:append)
        end

        arbre.append element_class, :one, :two, &block
      end

      it "should run the given block :append flow if no block is given" do
        block = proc do
          expect(arbre.current_flow).to be(:append)
        end

        arbre.append &block
      end

    end

    describe '#prepend' do

      it "should insert an element of the given class using the :prepend flow" do
        block = proc {}
        expect(arbre).to receive(:insert_element).with(element_class, :one, :two) do |&blk|
          expect(blk).to be(block)
          expect(arbre.current_flow).to be(:prepend)
        end

        arbre.prepend element_class, :one, :two, &block
      end

      it "should run the given block :prepend flow if no block is given" do
        block = proc do
          expect(arbre.current_flow).to be(:prepend)
        end

        arbre.prepend &block
      end

    end

  ######
  # After / before

    describe '#after' do
      let(:parent) { Element.new }
      let(:element) { Element.new }
      before { parent << element }

      it "should insert an element of the given class using the :after flow" do
        block = proc {}
        expect(arbre).to receive(:within_element).with(parent) do |&blk|
          blk.call
        end
        expect(arbre).to receive(:insert_element).with(element_class, :one, :two) do |&blk|
          expect(blk).to be(block)
          expect(arbre.current_flow).to eql([:after, element])
        end

        arbre.after element, element_class, :one, :two, &block
      end

      it "should run the given block :after flow if no block is given" do
        expect(arbre).to receive(:within_element).with(parent) do |&blk|
          blk.call
        end
        block = proc do
          expect(arbre.current_flow).to eql([:after, element])
        end

        arbre.after element, &block
      end

    end

    describe '#before' do
      let(:parent) { Element.new }
      let(:element) { Element.new }
      before { parent << element }

      it "should insert an element of the given class using the :before flow" do
        block = proc {}
        expect(arbre).to receive(:within_element).with(parent) do |&blk|
          blk.call
        end
        expect(arbre).to receive(:insert_element).with(element_class, :one, :two) do |&blk|
          expect(blk).to be(block)
          expect(arbre.current_flow).to eql([:before, element])
        end

        arbre.before element, element_class, :one, :two, &block
      end

      it "should run the given block :before flow if no block is given" do
        expect(arbre).to receive(:within_element).with(parent) do |&blk|
          blk.call
        end
        block = proc do
          expect(arbre.current_flow).to eql([:before, element])
        end

        arbre.before element, &block
      end

    end

  ######
  # Insert child

    describe '#insert_child' do

      let(:element) { Element.new(arbre) }
      let(:existing) { Element.new(arbre) }
      let(:child) { Element.new(arbre) }

      context "flow :append" do
        before { allow(arbre).to receive(:current_flow).and_return(:append) }

        it "should add the child to the element" do
          expect(element.children).to receive(:<<).with(child)
          element.insert_child child
        end
      end

      context "flow :prepend" do
        before { allow(arbre).to receive(:current_flow).and_return(:prepend) }

        it "should insert the child at the beginning of the element's children" do
          expect(element.children).to receive(:insert_at).with(0, child)
          element.insert_child child
        end

        it "should change the flow after inserting the first element" do
          expect(element.children).to receive(:insert_at).with(0, child)
          expect(arbre).to receive(:replace_current_flow).with([ :after, child ])
          element.insert_child child
        end
      end

      context "flow :after" do
        before { allow(arbre).to receive(:current_flow).and_return([:after, existing]) }

        it "should insert the child after the existing child" do
          expect(element.children).to receive(:insert_after).with(existing, child)
          element.insert_child child
        end

        it "should change the flow after inserting the first element" do
          expect(element.children).to receive(:insert_after).with(existing, child)
          expect(arbre).to receive(:replace_current_flow).with([ :after, child ])
          element.insert_child child
        end
      end

      context "flow :before" do
        before { allow(arbre).to receive(:current_flow).and_return([:before, existing]) }

        it "should insert the child before the existing child" do
          expect(element.children).to receive(:insert_before).with(existing, child)
          element.insert_child child
        end
      end

    end


  ######
  # Support

    describe '#temporary' do
      it "should build an element with the given block and return it" do
        block = proc {}
        expect(arbre).to receive(:build_element).with(Element) do |&blk|
          expect(blk).to be(block)
          element
        end
        expect(arbre.temporary(&block)).to be(element)
        expect(element).to be_orphan
      end
    end

    it "should delegate #current_element to the context" do
      current_element = Element.new
      expect(arbre).to receive(:current_element).and_return(current_element)

      element = Element.new(arbre)
      expect(element.current_element).to be(current_element)
    end

    it "should delegate #current_flow to the context" do
      current_flow = double(:flow)
      expect(arbre).to receive(:current_flow).and_return(current_flow)

      element = Element.new(arbre)
      expect(element.current_flow).to be(current_flow)
    end

end