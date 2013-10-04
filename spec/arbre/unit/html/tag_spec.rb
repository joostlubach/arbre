require 'spec_helper'

describe Arbre::Html::Tag do

  let(:tag){ Arbre::Html::Tag.new }

  describe "building a new tag" do
    before { tag.build "Hello World", :id => "my_id" }

    it "should set the contents to a string" do
      tag.content.should == "Hello World"
    end

    it "should set the hash of options to the attributes" do
      tag.attributes.should == { :id => "my_id" }
    end
  end

  describe "css class names" do

    it "should add a class" do
      tag.add_class "hello_world"
      tag.class_names.should == "hello_world"
    end

    it "should remove_class" do
      tag.add_class "hello_world"
      tag.class_names.should == "hello_world"
      tag.remove_class "hello_world"
      tag.class_names.should == ""
    end

    it "should not add a class if it already exists" do
      tag.add_class "hello_world"
      tag.add_class "hello_world"
      tag.class_names.should == "hello_world"
    end

    it "should seperate classes with space" do
      tag.add_class "hello world"
      tag.class_list.size.should == 2
    end

    it "should create a class list from a string" do
      tag = Arbre::Html::Tag.new
      tag.build(:class => "first-class")
      tag.add_class "second-class"
      tag.class_list.size.should == 2
    end

  end

end
