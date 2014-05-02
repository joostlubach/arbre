require 'spec_helper'

describe Arbre do

  let(:helpers) { double(:helpers) }
  let(:assigns) { {} }

  it "should render a single element" do
    arbre { span "Hello World" }
    expect(arbre).to be_rendered_as("<span>Hello World</span>")
  end

  it "should render all attributes properly" do
    arbre do
      div "test", :class => %w(one two), :style => {'one' => 'two'}, 'one' => 'two'
    end
    expect(arbre).to be_rendered_as(<<-HTML)
      <div class="one two" one="two" style="one: two;">test</div>
    HTML
  end

  it "should access assigns through instance variables" do
    assigns[:my_var] = 'Hello World'
    arbre { span @my_var }
    expect(arbre).to be_rendered_as("<span>Hello World</span>")
  end

  it "should allow access to helper methods" do
    expect(helpers).to receive(:my_helper).and_return('Hello World')
    arbre { span my_helper }
    expect(arbre).to be_rendered_as("<span>Hello World</span>")
  end

  it "should render a child element" do
    arbre do
      span do
        span "Hello World"
      end
    end

    expect(arbre).to be_rendered_as(<<-HTML)
      <span>
        <span>Hello World</span>
      </span>
    HTML
  end

  it "should render an unordered list" do
    arbre do
      ul do
        li "First"
        li "Second"
        li "Third"
      end
    end

    expect(arbre).to be_rendered_as(<<-HTML)
      <ul>
        <li>First</li>
        <li>Second</li>
        <li>Third</li>
      </ul>
    HTML
  end

  it "should allow local variables inside the tags" do
    arbre do
      first = "First"
      second = "Second"
      ul do
        li first
        li second
      end
    end

    expect(arbre).to be_rendered_as(<<-HTML)
      <ul>
        <li>First</li>
        <li>Second</li>
      </ul>
    HTML
  end

  it "should add children and nested" do
    arbre do
      div do
        ul
        li do
          li
        end
      end
    end

    expect(arbre).to be_rendered_as(<<-HTML)
      <div>
        <ul></ul>
        <li>
          <li></li>
        </li>
      </div>
    HTML
  end

  it "should allow flow" do
    arbre do
      div do
        span2 = span('Span 2')
        span1 = prepend { span 'Span 1' }
        span4 = after(span2) { span 'Span 4' }
        before(span4) { span 'Span 3' }
        span 'Span 5'
      end
    end

    expect(arbre).to be_rendered_as(<<-HTML)
      <div>
        <span>Span 1</span>
        <span>Span 2</span>
        <span>Span 3</span>
        <span>Span 4</span>
        <span>Span 5</span>
      </div>
    HTML
  end

  it "should allow adding elements relative to others using queries" do
    arbre do
      div1 = div(:class => 'div1')

      within('.div1') { span 'Span 1.1', :id => 'my-span' }
      after('.div1 > #my-span') { span 'Span 1.2' }
      after('.div1') { span 'Span 1.3' }
    end

    expect(arbre).to be_rendered_as(<<-HTML)
      <div class="div1">
        <span id="my-span">Span 1.1</span>
        <span>Span 1.2</span>
      </div>
      <span>Span 1.3</span>
    HTML
  end

  it "should pass the element in to the block if asked for" do
    arbre do
      div do |d|
        d.ul do
          li
        end
      end
    end

    expect(arbre).to be_rendered_as(<<-HTML)
      <div>
        <ul>
          <li></li>
        </ul>
      </div>
    HTML
  end


  it "should move content tags between parents" do
    arbre do
      div do
        span(ul(li))
      end
    end

    expect(arbre).to be_rendered_as(<<-HTML)
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
    arbre do
      div do |d|
        d.id = "my-tag"
        ul do
          li
        end
      end
    end

    expect(arbre).to be_rendered_as(<<-HTML)
      <div id="my-tag">
        <ul>
          <li></li>
        </ul>
      </div>
    HTML
  end

  it "should have the parent set on it" do
    item = nil
    list = nil

    arbre do
      list = ul do
        li "Hello"
        item = li("World")
      end
    end

    expect(item.parent).to be(list)
  end

  describe "html safe" do

    it "should escape the contents" do
      arbre do
        span("<br />")
      end

      expect(arbre).to be_rendered_as(<<-HTML)
        <span>&lt;br /&gt;</span>
      HTML
    end

    it "should return html safe strings" do
      arbre do
        span("<br />")
      end

      expect(arbre.to_s).to be_html_safe
    end

    it "should not escape html passed in" do
      arbre do
        span(span("<br />"))
      end

      expect(arbre).to be_rendered_as(<<-HTML)
        <span>
          <span>&lt;br /&gt;</span>
        </span>
      HTML
    end

    it "should escape the contents of attributes" do
      arbre do
        span(:class => "<br />")
      end

      expect(arbre).to be_rendered_as(<<-HTML)
        <span class="&lt;br /&gt;"></span>
      HTML
    end

  end


  describe 'indentation' do

    # All specs in this file use the be_rendered_as matcher, which ignores whitespace. These specs are explicitly
    # designed to exemplify the indentation pattern.

    it "should use proper indentation" do
      arbre { div(span('Test')) }

      expect(arbre.to_s).to eql(<<-HTML.gsub(/^ {8}/, '').chomp)
        <div>
          <span>Test</span>
        </div>
      HTML
    end

    it "should not indent containers" do
      arbre do
        div do
          append Arbre::Container do
            span 'One'
            span 'Two'
          end
        end
      end

      expect(arbre.to_s).to eql(<<-HTML.gsub(/^ {8}/, '').chomp)
        <div>
          <span>One</span>
          <span>Two</span>
        </div>
      HTML
    end

  end

end