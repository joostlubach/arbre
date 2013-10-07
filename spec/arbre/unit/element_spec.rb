require 'spec_helper'
include Arbre

describe Element do

  let(:element) { Element.new }

  ######
  # Context

    describe '#arbre_context' do

      it "should be a new one if none was specified" do
        context = Element.new.arbre_context
        expect(context).to be_a(Context)
      end

      it "should the specified one if one was specified" do
        context = Context.new
        expect(Element.new(context).arbre_context).to be(context)
      end

    end

    describe '#assigns' do

      it "should take assigns from the context" do
        expect(element.arbre_context).to receive(:assigns).and_return(:variable => :value)
        expect(element.assigns).to eql(:variable => :value)
      end

    end

    describe '#helpers' do

      it "should take helpers from the context" do
        helpers = double()
        expect(element.arbre_context).to receive(:helpers).and_return(helpers)
        expect(element.helpers).to be(helpers)
      end

    end

  ######
  # Hierarchy

    describe '#remove!' do
      it "should remove itself from its parent children" do
        element.parent = Element.new
        expect(element.parent.children).to receive(:remove).with(element)
        element.remove!
      end
    end

    describe '#children' do

      specify { expect(element.children).to be_a(ChildElementCollection) }

      it "should be empty by default" do
        expect(element.children).to be_empty
      end

    end

    describe '#has_children?' do
      it "should be false if the element has no children" do
        expect(element).not_to have_children
      end
      it "should be true if the element has children" do
        element << Element.new
        expect(element).to have_children
      end
    end

    describe '#empty?' do
      it "should be true if the element has no children" do
        expect(element).to be_empty
      end
      it "should be false if the element has children" do
        element << Element.new
        expect(element).not_to be_empty
      end
    end

    describe '#<<' do

      it "should add a child element" do
        child = Element.new
        element << child

        expect(element).to have(1).child
        expect(element.children[0]).to be(child)
      end

    end

    describe '#orphan?' do

      it "should be true if the element has no parent" do
        expect(element).to be_orphan
      end

      it "should be false if the element has a parent" do
        element.parent = Element.new
        expect(element).not_to be_orphan
      end

    end

    describe '#ancestors' do

      specify { expect(element.ancestors).to be_a(ElementCollection) }

      it "should be empty if the element is an orphan" do
        expect(element.ancestors).to be_empty
      end

      it "should list all ancestors from near to far" do
        element.parent = Element.new
        element.parent.parent = Element.new
        element.parent.parent.parent = Element.new
        expect(element.ancestors.to_a).to eql([ element.parent, element.parent.parent, element.parent.parent.parent ])
      end

    end

    describe '#descendants' do

      specify { expect(element.descendants).to be_a(ElementCollection) }

      it "should be empty if the element has no children" do
        expect(element.descendants).to be_empty
      end

      it "should list all descendants, where each element is appended after its parent" do
        child1, child2, grandchild11, grandchild21, grandchild22 = 5.times.collect { Element.new }

        element << child1 << child2
        child1 << grandchild11
        child2 << grandchild21 << grandchild22

        expect(element.descendants).to eq([
          child1, grandchild11,
          child2, grandchild21, grandchild22
        ])
      end

    end

  ######
  # Content

    describe '#content' do

      it "should be the string output by #children" do
        expect(element.children).to receive(:to_s).and_return('(CONTENT)')
        expect(element.content).to eql('(CONTENT)')
      end

    end

    describe '#content=' do

      it "should clear any children and add a text node with the given string" do
        element << Element.new << Element.new
        element.content = "(CONTENT)"

        expect(element).to have(1).child
        expect(element.children[0]).to be_a(TextNode)
        expect(element.content).to eql('(CONTENT)')
      end

      it "should clear any children and add a given element" do
        element << Element.new << Element.new
        child = Element.new
        element.content = child

        expect(element).to have(1).child
        expect(element.children[0]).to be(child)
      end

      it "should clear any children and add a given element collection" do
        element << Element.new << Element.new

        child1 = Element.new
        child2 = Element.new
        children = ElementCollection.new([child1, child2])
        element.content = children
        expect(element.children).to eq([child1, child2])
      end

    end

  ######
  # Set operations

    describe '#+' do

      it "should wrap itself in a collection and add the other element" do
        element2 = Element.new

        elements = element + element2
        expect(elements).to be_a(ElementCollection)
        expect(elements).to have(2).items
        expect(elements[0]).to be(element)
        expect(elements[1]).to be(element2)
      end

      it "should wrap itself in a collection and add the other elements" do
        element2 = Element.new
        element3 = Element.new

        elements = element + [ element2, element3 ]
        expect(elements).to be_a(ElementCollection)
        expect(elements).to have(3).items
        expect(elements[0]).to be(element)
        expect(elements[1]).to be(element2)
        expect(elements[2]).to be(element3)
      end

    end

  ######
  # Building & rendering

    it "should call any block passed into the #build method with the element as an argument, but not instance-exec'd" do
      receiver = nil
      received_arg = nil
      element.build! { |arg| receiver = self; received_arg = arg }
      expect(received_arg).to be(element)
      expect(receiver).to be(self)
    end

    it "should render its content by default" do
      expect(element).to receive(:content).and_return('(CONTENT)')
      expect(element.to_s).to eql('(CONTENT)')
    end

    it "should alias to_s as to_html" do
      expect(element).to receive(:to_s).and_return('(CONTENT)')
      expect(element.to_html).to eql('(CONTENT)')
    end

    it "should provide a terse description using #inspect" do
      expect(element.inspect).to match(/#<Arbre::Element:0x[0-9a-f]+>/)
    end

    it "should have an indentation level of 0 by default" do
      expect(element.indent_level).to eql(0)
    end

    it "should have an indentation level of 1 higher than its parent, if it has a parent" do
      element.parent = Element.new
      expect(element.parent).to receive(:indent_level).and_return(5)
      expect(element.indent_level).to eql(6)
    end

  ######
  # Helpers & assigns access

    it "should pass any missing method to a helper method" do
      result = double()
      allow(element).to receive(:helpers).and_return(double(:helpers))
      expect(element.helpers).to receive(:my_helper).and_return(result)
      expect(element.my_helper).to be(result)
      expect{element.my_other_helper}.to raise_error(NoMethodError)
    end

    it "should actually define the method when it is first found on the helpers" do
      allow(element).to receive(:helpers).and_return(double(:helpers))
      expect(element.helpers).to receive(:my_helper)
      element.my_helper

      expect(element.method(:my_helper)).not_to be_nil
    end

    it "should respond to any helper method" do
      result = double()
      allow(element).to receive(:helpers).and_return(double(:helpers))
      allow(element.helpers).to receive(:my_helper).and_return(result)
      expect(element).to respond_to(:my_helper)
      expect(element).not_to respond_to(:my_other_helper)
    end

    it "should not try a helper method if no helpers were found" do
      expect{ element.my_helper }.to raise_error(NoMethodError)
    end

    it "should offer any assigns as instance variables when the element is initialized with a context" do
      assigns = { :my_assign => :value }
      context = Context.new(assigns, double(:helpers))
      element = Element.new(context)

      expect(element.instance_variable_get("@my_assign")).to be(:value)
    end

end
