require 'spec_helper'

describe Arbre do

  let(:helpers){ nil }
  let(:assigns){ {} }

  it "should render a single element" do
    arbre {
      span "Hello World"
    }.render.should == "<span>Hello World</span>\n"
  end

  it "should render a child element" do
    arbre {
      span do
        span "Hello World"
      end
    }.render.should == <<-HTML
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
    }.render.should == <<-HTML
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
     }.render.should == <<-HTML
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
    }.render.should == <<-HTML
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
    }.render.should == <<-HTML
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
    }.render.should == <<-HTML
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
    }.render.should == <<-HTML
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

  it "should set a string content return value with no children" do
    arbre {
      li do
        "Hello World"
      end
    }.render.should == <<-HTML
<li>Hello World</li>
HTML
  end

  it "should turn string return values into text nodes" do
    arbre {
      list = li do
        "Hello World"
      end
      node = list.children.first
      node.class.should == Arbre::TextNode
    }
  end

  it "should not render blank arrays" do
    arbre {
      tbody do
        []
      end
    }.render.should == <<-HTML
<tbody></tbody>
HTML
  end

  describe "self-closing nodes" do

    it "should not self-close script tags" do
      arbre {
        script :type => 'text/javascript'
      }.render.should == "<script type=\"text/javascript\"></script>\n"
    end

    it "should self-close meta tags" do
      arbre {
        meta :content => "text/html; charset=utf-8"
      }.render.should == "<meta content=\"text/html; charset=utf-8\"/>\n"
    end

    it "should self-close link tags" do
      arbre {
        link :rel => "stylesheet"
      }.render.should == "<link rel=\"stylesheet\"/>\n"
    end

  end

  describe "html safe" do

    it "should escape the contents" do
      arbre {
        span("<br />")
      }.render.should == <<-HTML
<span>&lt;br /&gt;</span>
HTML
    end

    it "should return html safe strings" do
      arbre {
        span("<br />")
      }.render.should be_html_safe
    end

    it "should not escape html passed in" do
      arbre {
        span(span("<br />"))
      }.render.should == <<-HTML
<span>
  <span>&lt;br /&gt;</span>
</span>
HTML
    end

    it "should escape string contents when passed in block" do
      arbre {
        span {
          span {
            "<br />"
          }
        }
      }.render.should == <<-HTML
<span>
  <span>&lt;br /&gt;</span>
</span>
HTML
    end

    it "should escape the contents of attributes" do
      arbre {
        span(:class => "<br />")
      }.render.should == <<-HTML
<span class="&lt;br /&gt;"></span>
HTML
    end

  end

end
