require 'spec_helper'

describe Arbre do

  let(:helpers){ nil }
  let(:assigns){ {} }

  it "should render a single element" do
    arbre {
      span "Hello World"
    }.to_s.should == "<span>Hello World</span>"
  end

  it "should render a child element" do
    arbre {
      span do
        span "Hello World"
      end
    }.to_s.should == <<-HTML.chomp
<span>
  <span>Hello World</span>
</span>
HTML
  end

  it "should render an unordered list" do
    arbre {
      ul do
        li "First"
        li "Second"
        li "Third"
      end
    }.to_s.should == <<-HTML.chomp
<ul>
  <li>First</li>
  <li>Second</li>
  <li>Third</li>
</ul>
HTML
  end

   it "should allow local variables inside the tags" do
     arbre {
       first = "First"
       second = "Second"
       ul do
         li first
         li second
       end
     }.to_s.should == <<-HTML.chomp
<ul>
  <li>First</li>
  <li>Second</li>
</ul>
HTML
   end


  it "should add children and nested" do
    arbre {
      div do
        ul
        li do
          li
        end
      end
    }.to_s.should == <<-HTML.chomp
<div>
  <ul></ul>
  <li>
    <li></li>
  </li>
</div>
HTML
  end


  it "should pass the element in to the block if asked for" do
    arbre {
      div do |d|
        d.ul do
          li
        end
      end
    }.to_s.should == <<-HTML.chomp
<div>
  <ul>
    <li></li>
  </ul>
</div>
HTML
  end


  it "should move content tags between parents" do
    arbre {
      div do
        span(ul(li))
      end
    }.to_s.should == <<-HTML.chomp
<div>
  <span>
    <ul>
      <li></li>
    </ul>
  </span>
</div>
HTML
  end

  it "should add content to the parent if the element is passed into block" do
    arbre {
      div do |d|
        d.id = "my-tag"
        ul do
          li
        end
      end
    }.to_s.should == <<-HTML.chomp
<div id="my-tag">
  <ul>
    <li></li>
  </ul>
</div>
HTML
  end

  it "should have the parent set on it" do
    arbre {
      item = nil
      list = ul do
        li "Hello"
        item = li "World"
      end
      item.parent.should == list
    }
  end

  describe "html safe" do

    it "should escape the contents" do
      arbre {
        span("<br />")
      }.to_s.should == <<-HTML.chomp
<span>&lt;br /&gt;</span>
HTML
    end

    it "should return html safe strings" do
      arbre {
        span("<br />")
      }.to_s.should be_html_safe
    end

    it "should not escape html passed in" do
      arbre {
        span(span("<br />"))
      }.to_s.should == <<-HTML.chomp
<span>
  <span>&lt;br /&gt;</span>
</span>
HTML
    end

    it "should escape the contents of attributes" do
      arbre {
        span(:class => "<br />")
      }.to_s.should == <<-HTML.chomp
<span class="&lt;br /&gt;"></span>
HTML
    end

  end

end
