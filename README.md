# Arbre - Ruby Object Oriented HTML Views

Arbre is the DOM implemented in Ruby. This project is primarily used as
the object oriented view layer in Active Admin.

{<img src="https://secure.travis-ci.org/yoazt/arbre.png?branch=master" alt="Build Status" />}[http://travis-ci.org/yoazt/arbre]

## Simple Usage

A simple example of setting up an Arbre context and creating some html

    html = Arbre::Context.new do
      h2 "Why Arbre is awesome?"

      ul do
        li "The DOM is implemented in ruby"
        li "You can create object oriented views"
        li "Templates suck"
      end
    end

    puts html.to_s #=> <h2>Why</h2><ul><li></li></ul>


## The DOM in Ruby

The purpose of Arbre is to leave the view as ruby objects as long
as possible. This allows OO Design to be used to implement the view layer.


    html = Arbre::Context.new do
      h2 "Why Arbre is awesome?"
    end

    html.children.size #=> 1
    html.children.first #=> #<Arbre::Html::H2>

It is easy to extend your DOM tree as well.

    arbre = Arbre::Context.new do
      h2 "Why Arbre is awesome?"

      ul do
        li "The DOM is implemented in ruby"
        li "You can create object oriented views"
      end

      within 'ul' do
        li "Templates suck"
      end
      before 'li:last' do
        li "I forgot:"
      end
    end

## Custom elements

The purpose of Arbre is to be able to create shareable and extendable HTML
elements. To do this, you create a subclass of any Arbre HTML element:

For example:

    class Panel < Arbre::Html::Section
      builder_method :panel

      def build!(title, attributes = {})
        super attributes

        h3 title, class: "panel-title"
      end
    end

The `builder_method` defines the method that will be called to build this component
when using the DSL. The arguments passed into the `builder_method` will be passed
into the `#build!` method for you.

You can now use this panel in any Arbre context:

    html = Arbre::Context.new do
      panel "Hello World", id: "my-panel" do
        span "Inside the panel"

        after('h3') { sub "This is inserted after the title." }
      end
    end

    html.to_s #=>
      # <div class='panel' id="my-panel">
      #   <h3 class='panel-title'>Hello World</h3>
      #   <sub>This is inserted after the title.</sub>
      #   <span>Inside the panel</span>
      # </div>
