require 'spec_helper'
include Arbre::Html

describe Document do

  it "should by default be rendered as an empty document" do
    arbre.append Document

    expect(arbre).to be_rendered_as(<<-HTML)
      <!DOCTYPE html>

      <html>
        <head>
          <meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
        </head>
        <body>
        </body>
      </html>
    HTML
  end

  it "should allow content to be appended to the head using the #head method" do
    arbre do
      append Document do |doc|
        doc.head { title "My Title" }
      end
    end

    expect(arbre).to be_rendered_as(<<-HTML)
      <!DOCTYPE html>

      <html>
        <head>
          <meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
          <title>My Title</title>
        </head>
        <body>
        </body>
      </html>
    HTML
  end

  it "should allow content to be appended to the body using the #body method" do
    arbre do
      append Document do |doc|
        doc.body { div 'Content Area' }
      end
    end

    expect(arbre).to be_rendered_as(<<-HTML)
      <!DOCTYPE html>

      <html>
        <head>
          <meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
        </head>
        <body>
          <div>Content Area</div>
        </body>
      </html>
    HTML
  end

end