require 'spec_helper'
include Arbre

describe Context do

  ######
  # Attributes

    it "should not allow a parent to be set" do
      expect{ Context.new.parent = Element.new }.to raise_error(NotImplementedError)
    end

    it "should always have an indentation level of -1" do
      context = Context.new
      expect(context.indent_level).to eql(-1)
    end

    describe '#assigns' do
      it "should be its own assigns" do
        expect(Context.new.assigns).to eql({})
        expect(Context.new(:one => :two).assigns).to eql(:one => :two)
      end
      it "should have symbolic keys only" do
        expect(Context.new('one' => :two).assigns).to eql(:one => :two)
      end
    end

    describe '#helpers' do
      it "should be its own helpers" do
        expect(Context.new.helpers).to eql(nil)
        helpers = double()
        expect(Context.new({}, helpers).helpers).to be(helpers)
      end
    end

  ######
  # Element & flow stack

    let(:context) { Context.new }

    it "should have the context itself as the current element" do
      expect(context.current_element).to be(context)
    end

    it "should have :append as the current flow" do
      expect(context.current_flow).to be(:append)
    end

    it "should change the current element and flow temporarily using #with_current" do
      element1 = Element.new
      element2 = Element.new

      expect(context.current_element).to be(context)
      expect(context.current_flow).to be(:append)
      context.with_current element: element1, flow: :prepend do
        expect(context.current_element).to be(element1)
        expect(context.current_flow).to be(:prepend)
        context.with_current element: element2, flow: [ :after, element1 ] do
          expect(context.current_element).to be(element2)
          expect(context.current_flow).to eql([ :after, element1 ])
        end
        expect(context.current_element).to be(element1)
        expect(context.current_flow).to be(:prepend)
      end
      expect(context.current_element).to be(context)
      expect(context.current_flow).to be(:append)
    end

    it "should replace the original element if an error occurs" do
      begin
        context.with_current(element: Element.new, flow: :prepend) { raise 'test' }
      rescue
        expect(context.current_element).to be(context)
        expect(context.current_flow).to be(:append)
      end
    end

    describe '#replace_current_flow' do
      # Note - this method is for internal purposes only.

      it "should replace the current flow" do
        element = Element.new

        expect(context.current_flow).to be(:append)
        context.with_current element: element, flow: :prepend do
          expect(context.current_flow).to be(:prepend)
          context.replace_current_flow [ :after, element ]
          expect(context.current_flow).to eql([:after, element])
        end
        expect(context.current_flow).to be(:append)
      end

    end

end
