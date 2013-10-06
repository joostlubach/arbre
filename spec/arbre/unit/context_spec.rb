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

    it "should change the current element temporarily using #within" do
      element1 = Element.new
      element2 = Element.new

      expect(context.current_element).to be(context)
      context.within element1 do
        expect(context.current_element).to be(element1)
        context.within element2 do
          expect(context.current_element).to be(element2)
        end
        expect(context.current_element).to be(element1)
      end
      expect(context.current_element).to be(context)
    end

    it "should replace the original element if an error occurs" do
      begin
        context.within(Element.new) { raise 'test' }
      rescue
        expect(context.current_element).to be(context)
      end
    end

    it "should change the current flow temporarily using #with_flow" do
      element = Element.new

      expect(context.current_flow).to be(:append)
      context.with_flow :prepend do
        expect(context.current_flow).to be(:prepend)
        context.with_flow [ :after, element ] do
          expect(context.current_flow).to eql([:after, element])
        end
        expect(context.current_flow).to be(:prepend)
      end
      expect(context.current_flow).to be(:append)
    end

    it "should replace the original element if an error occurs" do
      begin
        context.with_flow(:prepend) { raise 'test' }
      rescue
        expect(context.current_flow).to be(:append)
      end
    end

    describe '#replace_current_flow' do
      # Note - this method is for internal purposes only.

      it "should replace the current flow" do
        element = Element.new

        expect(context.current_flow).to be(:append)
        context.with_flow :prepend do
          expect(context.current_flow).to be(:prepend)
          context.replace_current_flow [ :after, element ]
          expect(context.current_flow).to eql([:after, element])
        end
        expect(context.current_flow).to be(:append)
      end

    end

  ######
  # HTML caching

    it "should forward methods to the rendered string, and cache it" do
      expect(arbre).to receive(:content).once.and_return('<span>(Test)</span>')

      expect(arbre).to respond_to(:length)
      expect(arbre).to respond_to(:bytesize)
      expect(arbre).to respond_to(:gsub)

      expect(arbre.length).to eql(19)
      expect(arbre.bytesize).to eql(19)
      expect(arbre.gsub(/span/, 'div')).to eql('<div>(Test)</div>')
    end

    it "should not pass a method on to cached_html if the context has not finished rendering" do
      expect(arbre).to receive(:content) do
        # Arbre is now in the process of being rendered
        expect(arbre).not_to respond_to(:length)
        expect(arbre).not_to respond_to(:bytesize)
        expect(arbre).not_to respond_to(:gsub)
      end

      arbre.to_html
    end

end
