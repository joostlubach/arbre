require 'spec_helper'
include Arbre

describe Html::Comment do

  it "should render an empty comment" do
    expect(arbre.comment.to_s).to eql('<!-- -->')
  end

  it "should render a single-line comment" do
    comment = arbre.comment("This is a comment")
    expect(comment.to_s).to eql('<!-- This is a comment -->')
  end

  it "should render a multi-line comment" do
    comment = arbre.comment("This is a comment\ncontaining two lines")
    expect(arbre.to_s).to eql(<<-HTML.gsub(/^ {6}/, '').chomp)
      <!--
        This is a comment
        containing two lines
      -->
    HTML
  end

  it "should use proper indentation" do
    arbre do
      div do
        comment "This is an indented comment\ncontaining two lines"
      end
    end

    expect(arbre.to_s).to eql(<<-HTML.gsub(/^ {6}/, '').chomp)
      <div>
        <!--
          This is an indented comment
          containing two lines
        -->
      </div>
    HTML
  end

end