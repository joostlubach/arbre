require 'spec_helper'
include Arbre::Html

describe Document do

  it "should by default be rendered as an empty document" do
    expect(arbre.append(Document)).to be_rendered_as(<<-HTML)
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

end