require 'rails_spec_helper'

describe Arbre::Rails::RSpec::ArbreSupport, arbre: true do

  let(:example) { self }
  subject { example }

  describe '#arbre_context' do
    let(:assigns) { double(:assigns) }
    let(:helpers) { double(:helpers) }

    it "should build and memoize an Arbre context" do
      context = double(:context)
      expect(Arbre::Context).to receive(:new).once.with(assigns, helpers).and_return(context)
      expect(example.arbre_context).to be(context)
    end

    it "should be aliased as #arbre" do
      context = double(:context)
      expect(Arbre::Context).to receive(:new).once.with(assigns, helpers).and_return(context)
      expect(example.arbre_context).to be(context)
      expect(example.arbre).to be(context)
    end
  end

  its(:assigns) { should eql({}) }

  describe '#helpers' do
    it "should build and memoize helpers" do
      helpers = double(:helpers)
      expect(example).to receive(:build_helpers).once.and_return(helpers)
      expect(example.helpers).to be(helpers)
      expect(example.helpers).to be(helpers)
    end
  end

  describe '#build_helpers' do
    let(:helpers) { example.build_helpers }

    specify { expect(helpers).to be_a(ActionView::Base) }
    specify { expect(helpers.controller).to be(controller) }
    specify { expect(helpers.request).to be(request) }

    it "should mock an asset_path helper" do
      expect(helpers.asset_path('test')).to eql('/assets/test')
    end

    it "should include any ApplicationController helpers if an ApplicationController exists" do
      if defined?(::ApplicationController)
        prev_app_controller = ::ApplicationController
        Object.send :remove_const, :ApplicationController
      end
      ::ApplicationController = Class.new(ActionController::Base)
      app_helpers = Module.new do
        def my_method; 'result' end
      end
      expect(::ApplicationController).to receive(:_helpers).and_return(app_helpers)

      expect(helpers.my_method).to eql('result')
      Object.send :remove_const, :ApplicationController
      ::ApplicationController = prev_app_controller if prev_app_controller
    end

  end

  describe '#controller' do
    specify { expect(example.controller).to be_a(ActionController::Base) }
    specify { expect(example.controller.request).to be(example.request) }
  end

  describe '#request' do
    specify { expect(example.request).to be_a(ActionDispatch::Request) }
  end

end