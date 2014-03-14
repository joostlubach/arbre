require 'spec_helper'
include Arbre::Html

describe StyleHash do

  describe "initializer" do
    it "should be able to be initialized without arguments" do
      hash = StyleHash.new
      expect(hash).to be_empty
    end

    it "should be able to be initialized with a hash" do
      hash = StyleHash.new('one' => 'two')
      expect(hash.to_s).to eql('one: two;')
    end

    it "should be able to be initialized with a string containing a style definition" do
      hash = StyleHash.new('one: two; three:four;')
      expect(hash.to_s).to eql('one: two; three: four;')
    end

    it "should convert to dash-case when initialized with a hash" do
      hash = StyleHash.new('styleOne' => 'two')
      expect(hash.to_s).to eql('style-one: two;')
    end

  end

  describe '#style' do
    it "should be an alias to itself" do
      hash = StyleHash.new('one:two;')
      expect(hash.style).to be(hash)
    end
  end

  describe '[]=' do
    it "should convert the used name to dash-case" do
      hash = StyleHash.new
      hash[:style_one] = 'one'
      hash[:style_two] = 'two'
      hash['style-three'] = 'three'
      hash['styleFour'] = 'four'
      expect(hash.to_s).to eql('style-one: one; style-two: two; style-three: three; style-four: four;')
    end
  end

  describe '[]' do
    it "should convert the used name to dash-case" do
      hash = StyleHash.new('style-one: one; style-two: two; style-three: three; style-four: four;')
      expect(hash[:style_one]).to eql('one')
      expect(hash[:style_two]).to eql('two')
      expect(hash['style-three']).to eql('three')
      expect(hash['styleFour']).to eql('four')
    end
  end

end
