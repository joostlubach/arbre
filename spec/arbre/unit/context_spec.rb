# coding: utf-8
require 'spec_helper'

describe Arbre::Context do

  let(:context) do
    Arbre::Context.new do
      h1 "札幌市北区" # Add some HTML to the context
    end
  end

  it "should not increment the indent_level" do
    context.indent_level.should == -1
  end

end
