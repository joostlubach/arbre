require 'spec_helper'
include Arbre

describe TextNode do

  it "should accept only a string in its build method" do
    node = arbre.append(TextNode, 'Test')
    expect(node.text).to eql('Test')
  end

  it "should be buildable using :text_node" do
    node = arbre.text_node('Test')
    expect(node).to be_a(TextNode)
    expect(node.text).to eql('Test')
  end

  it "should be able to be created from a string" do
    node = TextNode.from_string('Test')
    expect(node.text).to eql('Test')
  end

  it "should render its text only" do
    node = TextNode.new
    expect(node).to receive(:text).and_return('Test')
    expect(node.to_s).to eql('Test')
  end

  it "should be HTML safe" do
    node = TextNode.new
    expect(node).to receive(:text).and_return('<>')
    expect(node.to_s).to eql('&lt;&gt;')
    expect(node).to receive(:text).and_return('<>'.html_safe)
    expect(node.to_s).to eql('<>')
  end

  it "should always have an empty child collection" do
    node = TextNode.new
    expect(node.children).to be_empty
  end

  it "should be disallowed to add any children" do
    node = TextNode.new
    expect{ node.children << Element.new }.to raise_error(NotImplementedError)
    expect{ node.children.add Element.new }.to raise_error(NotImplementedError)
    expect{ node.children.concat [ Element.new ] }.to raise_error(NotImplementedError)
  end

end