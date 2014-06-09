require 'spec_helper'

require 'arbre/rails/layouts'
Arbre::Context.send :include, Arbre::Rails::Layouts::ContextMethods

describe Arbre::Rails::Layouts do

  # Layouts are also integration-specced in integration/rails_spec.rb.
  let(:controller) { double() }

  before do
    allow(helpers).to receive(:controller).and_return(controller)
    allow(helpers).to receive(:request).and_return(double(:xhr? => false))
    controller.singleton_class.send :include, Arbre::Rails::Layouts::ControllerMethods
  end

  describe '#layout' do

    context "not having specified a document (i.e. a non-Arbre content template)" do
      it "should use the current legacy document" do
        legacy_document_class = Class.new(Arbre::Html::Document)
        expect(Arbre::Rails).to receive(:legacy_document).and_return(legacy_document_class)

        arbre.layout
        expect(arbre.children.first).to be_a(legacy_document_class)
      end

      it "should run a given layout block on it" do
        legacy_document_class = Class.new(Arbre::Html::Document) do
          def self.name; 'LayoutsExample::LegacyDocument' end
        end
        expect(Arbre::Rails).to receive(:legacy_document).and_return(legacy_document_class)

        receiver = nil
        layout_block = proc { receiver = self }

        arbre.layout &layout_block
        expect(receiver).to be(arbre.children.first)
      end
    end

    context "having specified a document but not a content block" do
      it "should use the document class and arguments" do
        document_class = Class.new(Arbre::Html::Document)
        expect_any_instance_of(document_class).to receive(:build!).with(:one, :two)

        arbre.document document_class, :one, :two
        arbre.layout
        expect(arbre.children.first).to be_a(document_class)
      end

      it "should run a given layout block on it" do
        document_class = Class.new(Arbre::Html::Document)

        receiver = nil
        layout_block = proc { receiver = self }

        arbre.document document_class
        arbre.layout &layout_block
        expect(receiver).to be(arbre.children.first)
      end
    end

    context "having specified a document and a content block" do

      it "should use the document class, arguments and content block" do
        document_class = Class.new(Arbre::Html::Document)

        called = false
        block = proc { called = true }
        expect_any_instance_of(document_class).to receive(:build!).with(:one, :two) do |&blk|
          blk.call
        end

        arbre.document document_class, :one, :two, &block
        arbre.layout
        expect(arbre.children.first).to be_a(document_class)
        expect(called).to be_truthy
      end

      it "should execute the content block on the document if it was not called from its build! method" do
        document_class = Class.new(Arbre::Html::Document) do
          def self.name; 'LayoutsExample::MyDocumentClass' end
        end

        called = false
        receiver = nil
        block = proc { called = true; receiver = self }
        expect_any_instance_of(document_class).to receive(:build!).with(:one, :two)

        arbre.document document_class, :one, :two, &block
        arbre.layout
        expect(arbre.children.first).to be_a(document_class)
        expect(called).to be_truthy
        expect(receiver).to be(arbre.children.first)
      end

      it "should run a given layout block on it, before the document's build! method" do
        called = []; receivers = []

        document_class = Class.new(Arbre::Html::Document) do
          def self.name; 'LayoutsExample::MyDocumentClass' end
        end

        expect_any_instance_of(document_class).to receive(:build!) { called << :build! }
        layout_block = proc { called << :layout; receivers << self }
        content_block = proc { called << :content; receivers << self }

        arbre.document document_class, &content_block
        arbre.layout &layout_block
        expect(called).to eql([:layout, :build!, :content])
        expect(receivers[0]).to be(arbre.children.first)
        expect(receivers[1]).to be(arbre.children.first)
      end

    end

    it "should not call a layout block if this is an AJAX request" do
      expect(helpers.request).to receive(:xhr?).and_return(true)

      document_class = Class.new(Arbre::Html::Document)

      called = []
      content_block = proc { called << :content }
      layout_block = proc { called << :layout }

      arbre.document document_class, &content_block
      arbre.layout &layout_block
      expect(called).to eql([ :content ])
    end

  end

end