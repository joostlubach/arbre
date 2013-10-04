require 'spec_helper'
include Arbre

describe Container do

  it "should render its content" do
    container = Container.new
    expect(container).to receive(:content).and_return('(CONTENT)')
    expect(container.to_s).to eql('(CONTENT)')
  end

  it "should have an indentation level of 0 by default" do
    expect(Container.new.indent_level).to eql(0)
  end

  it "should have the same indentation level as its parent" do
    container = Container.new
    container.parent = Element.new
    expect(container.parent).to receive(:indent_level).and_return(5)
    expect(container.indent_level).to eql(5)
  end

end