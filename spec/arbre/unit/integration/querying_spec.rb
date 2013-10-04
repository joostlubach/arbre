require 'spec_helper'
include Arbre

describe 'Querying' do

  let(:arbre) do
    Arbre::Context.new do
      div :id => 'one'
      div :id => 'two' do
        a 'Link 1', :href => '/', :class => 'one two'

        input :type => :checkbox, 'data-attribute' => 'some_value'
        input :type => 'file'

        insert_element Container do
          span :id => 'in_container'
          a 'Link 2', :href => '/blah', :class => 'external two', :target => '_blank'
        end
      end
      div :id => 'three' do
        a 'Link 3', :class => 'three'

        div do
          a 'Link 4', :class => 'four'
        end
      end
    end
  end

  it "should find all descendants using the '*' selector" do
    elements = "[<div#one>, <div#two>, <a.one.two>, <input[type=checkbox]>, <input[type=file]>, <span#in_container>, <a.external.two>, <div#three>, <a.three>, <div>, <a.four>]"
    expect(arbre.find('*').to_a.inspect).to eql(elements)
  end

  it "should find all links using 'a'" do
    result = arbre.find('a')
    expect(result.to_a.inspect).to eql('[<a.one.two>, <a.external.two>, <a.three>, <a.four>]')
  end

  it "should find all external links using 'a.external'" do
    result = arbre.find('a.external')
    expect(result.to_a.inspect).to eql('[<a.external.two>]')
  end

  it "should find only direct children using a direct child operator" do
    result = arbre.find('div#two > a.external')
    expect(result.to_a.inspect).to eql('[<a.external.two>]')
  end

  it "should match all given classes" do
    result = arbre.find('a.one.two')
    expect(result.to_a.inspect).to eql('[<a.one.two>]')
  end

  describe 'pseudo selectors' do

    it "should accept the :first pseudo selector" do
      result = arbre.find('a:first')
      expect(result.to_a.inspect).to eql('[<a.one.two>]')
    end

    it "should accept the :last pseudo selector" do
      result = arbre.find('a:last')
      expect(result.to_a.inspect).to eql('[<a.four>]')
    end

    it "should accept the :first-child pseudo selector" do
      result = arbre.find('a:first-child')
      expect(result.to_a.inspect).to eql('[<a.one.two>, <a.three>, <a.four>]')
    end

    it "should accept the :last-child pseudo selector" do
      result = arbre.find('a:last-child')
      expect(result.to_a.inspect).to eql('[<a.external.two>, <a.four>]')
    end

    it "should accept multiple pseudo selectors" do
      result = arbre.find('a:first-child:last-child')
      expect(result.to_a.inspect).to eql('[<a.four>]')
    end

  end

  describe 'attribute selectors' do

    it "should accept an attribute selector without a value" do
      result = arbre.find('a[href]')
      expect(result.to_a.inspect).to eql('[<a.one.two>, <a.external.two>]')
    end

    it "should accept an attribute selector with a value" do
      result = arbre.find('input[type=checkbox]')
      expect(result.to_a.inspect).to eql('[<input[type=checkbox]>]')
    end

    it "should accept an attribute selector with a dash and a quoted value" do
      result = arbre.find('input[data-attribute="some_value"]')
      expect(result.to_a.inspect).to eql('[<input[type=checkbox]>]')
    end

    it "should accept multiple attribute selectors" do
      result = arbre.find('a[href="/blah"][target]')
      expect(result.to_a.inspect).to eql('[<a.external.two>]')
    end

  end

  it "should allow various selector properties to be combined" do
    result = arbre.find('a.two:last')
    expect(result.to_a.inspect).to eql('[<a.external.two>]')
  end

  it "should allow a descendant selector" do
    result = arbre.find('#three a')
    expect(result.to_a.inspect).to eql('[<a.three>, <a.four>]')
  end

  it "should allow a child selector" do
    result = arbre.find('#three > a')
    expect(result.to_a.inspect).to eql('[<a.three>]')
  end

  it "should find something inside a container" do
    result = arbre.find('#in_container')
    expect(result.to_a.inspect).to eql('[<span#in_container>]')
  end

  it "should find something 'through' a container" do
    result = arbre.find('#two > #in_container')
    expect(result.to_a.inspect).to eql('[<span#in_container>]')
  end

end
