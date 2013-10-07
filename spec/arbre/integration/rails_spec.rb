require 'rails_spec_helper'

describe Arbre::Rails, :type => :request do

  # Describes Rails integration. Refer to spec/rails/example_app for an example application.
  # The application offers one controller action mapped to the root path, which can take
  # the name of a template and/or a layout to render.

  let(:body) { response.body }

  ######
  # Content / layout

    it "should render an ERB template without a layout" do
      get '/', :template => 'erb', :layout => false
      expect(body).to be_rendered_as('<h1>This is an ERB template</h1>')
    end

    it "should render an Arbre template without a layout" do
      get '/', :template => 'arbre', :layout => false
      expect(body).to be_rendered_as('<h1>This is an Arbre template</h1>')
    end

    it "should render an ERB template with an empty Arbre layout" do
      get '/', :template => 'erb', :layout => 'empty'
      expect(body).to be_rendered_as(<<-HTML)
        <!DOCTYPE html>

        <html>
          <head>
            <meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
            <meta http-equiv="Author" content="Me" />
          </head>
          <body>
            <h1>This is an ERB template</h1>
          </body>
        </html>
      HTML
    end

    it "should render an ERB template with an Arbre layout that sets a title" do
      get '/', :template => 'erb', :layout => 'with_title'
      expect(body).to be_rendered_as(<<-HTML)
        <!DOCTYPE html>

        <html>
          <head>
            <title>Application Title</title>
            <meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
            <meta http-equiv="Author" content="Me" />
          </head>
          <body>
            <h1>This is an ERB template</h1>
          </body>
        </html>
      HTML
    end

    it "should allow the legacy document class to be overridden" do
      Arbre::Rails.legacy_document = Class.new(Arbre::Html::Document) do
        def build!
          super

          head do
            text_node helpers.content_for(:head)
            text_node helpers.content_for(:styles)
          end
          body do
            div id: 'content-container' do
              text_node helpers.content_for(:layout)
            end
          end
        end
      end

      get '/', :template => 'erb', :layout => 'empty'
      expect(body).to be_rendered_as(<<-HTML)
        <!DOCTYPE html>

        <html>
          <head>
            <meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
            <meta http-equiv="Author" content="Me" />
          </head>
          <body>
            <div id="content-container">
             <h1>This is an ERB template</h1>
           </div>
          </body>
        </html>
      HTML

      Arbre::Rails.legacy_document = nil
    end

    it "should render an Arbre template with an empty Arbre layout" do
      get '/', :template => 'arbre', :layout => 'empty'
      expect(body).to be_rendered_as(<<-HTML)
        <!DOCTYPE html>

        <html>
          <head>
            <meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
          </head>
          <body>
            <h1>This is an Arbre template</h1>
          </body>
        </html>
      HTML
    end

    it "should render an Arbre template with an Arbre layout that sets a title" do
      get '/', :template => 'arbre', :layout => 'with_title'
      expect(body).to be_rendered_as(<<-HTML)
        <!DOCTYPE html>

        <html>
          <head>
            <title>Application Title</title>
            <meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
          </head>
          <body>
            <h1>This is an Arbre template</h1>
          </body>
        </html>
      HTML
    end

  ######
  # Partial / sub-template rendering

    it "should re-use a context when using method `partial' and the partial is also Arbre" do
      get '/', :template => 'partials', :layout => false

      expect(body).to be_rendered_as(%r[
        <p>Main template: Context Object ID=(\d+)</p>
        <div id="arbre">
          <p>Partial: Local1=local1, Context Object ID=(\d+)</p>
        </div>
        <div id="arbre-using-render">
          <p>Partial: Context Object ID=(\d+)</p>
        </div>
        <div id="erb">
          <p>ERB template.</p>
        </div>
      ]x)

      # Make sure that the context is re-used between the first two, but not in the case of 'render'.
      (ctx1_id,_), (ctx2_id,_), (ctx3_id,_) = body.scan(/Context Object ID=(\d+)/)
      expect(ctx1_id).to eql(ctx2_id)
      expect(ctx1_id).not_to eql(ctx3_id)
    end

    it "should return an empty string if an Arbre context is re-used" do
      get '/partial', :context => true
      expect(body).to be_rendered_as('')
    end

    it "should not return an empty string if an Arbre context is not re-used" do
      get '/partial', :context => false
      expect(body).to be_rendered_as(%r[^<p>Partial: Context Object ID=(\d+)</p>$])
    end

    it "should handle an Arbre template without converting the template to a string" do
      get '/', :template => 'arbre_partial_result', :layout => false
      expect(body).to be_rendered_as(%r[
        <p>Partial: Context Object ID=(\d+)</p>
        <p>The previous element is a Arbre::Html::P</p>
      ]x)
    end

    it "should wrap any other partial in a TextNode" do
      get '/', :template => 'erb_partial_result', :layout => false
      expect(body).to be_rendered_as(%r[
        <p>ERB template.</p>
        <p>The previous element is a Arbre::TextNode</p>
      ]x)
    end

end