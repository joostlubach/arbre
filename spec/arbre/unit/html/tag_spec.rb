require 'spec_helper'
include Arbre::Html

describe Tag do

  let(:tag) { Arbre::Html::Tag.new }

  ######
  # Building

    it "should use the first argument as content if it is given" do
      tag.build! "Content"
      expect(tag.content).to eql('Content')
    end

    it "should accept attributes" do
      tag.build! 'id' => 'my-tag'
      expect(tag.content).to eql('')
      expect(tag.id).to eql('my-tag')
    end

    it "should accept content and attributes" do
      tag.build! "Content", 'id' => 'my-tag'
      expect(tag.content).to eql('Content')
      expect(tag.id).to eql('my-tag')
    end

    it "should accept symbolic keyword arguments as attributes as well" do
      tag.build! "Content", 'id' => 'my-tag', :class => 'custom'
      expect(tag.content).to eql('Content')
      expect(tag.id).to eql('my-tag')
      expect(tag.classes.to_a).to eql(['custom'])
    end

    it "should require #tag_name to be implemented" do
      expect{ tag.tag_name }.to raise_error(NotImplementedError)
    end

  ######
  # DSL

    describe '.tag' do
      it "should define the method tag_name on the class" do
        klass = Class.new(Arbre::Html::Tag) { tag :span }
        expect(klass.new.tag_name).to eql('span')
      end

      it "should use the same tag name for derived classes" do
        superclass = Class.new(Arbre::Html::Tag) { tag :span }
        subclass   = Class.new(superclass)
        expect(subclass.new.tag_name).to eql('span')
      end
    end

    describe '.id' do
      it "should add the given ID to the tag" do
        klass = Class.new(Arbre::Html::Div) { id 'my-div' }
        expect(klass.new.tag_id).to eql('my-div')
        expect(klass.new.build!).to be_rendered_as('<div id="my-div"></div>')
      end

      it "should also add the ID to subclasses" do
        superclass = Class.new(Arbre::Html::Div) { id 'my-div' }
        expect(Class.new(superclass).new.tag_id).to eql('my-div')
      end

      it "should be able to be overridden in the build method" do
        klass = Class.new(Arbre::Html::Div) do
          id 'my-div'
          def build!
            self.id = 'overridden'
            super
          end
        end
        expect(klass.new.build!).to be_rendered_as('<div id="overridden"></div>')
      end
    end

    describe '.tag_classes' do
      it "should add the given classes to the tag" do
        klass = Class.new(Arbre::Html::Div) { classes 'time-input' }
        expect(klass.new.tag_classes).to eql(%w[time-input])
        expect(klass.new.build!).to be_rendered_as('<div class="time-input"></div>')
      end

      it "should flatten all given classes and allow space separated classes" do
        klass = Class.new(Arbre::Html::Div) { classes 'one two', 'three', %w[four five] }
        expect(klass.new.build!).to be_rendered_as('<div class="one two three four five"></div>')
      end

      it "should also add the classes to subclasses" do
        superclass = Class.new(Arbre::Html::Div) { classes 'time-input' }
        expect(Class.new(superclass).new.tag_classes).to eql(%w[time-input])
      end

      it "should combine classes with any given to the build! method" do
        klass = Class.new(Arbre::Html::Div) { classes 'one two' }
        expect(klass.new.build!(:class => 'three')).to be_rendered_as('<div class="one two three"></div>')
      end
    end

  ######
  # Attributes

    specify { expect(tag.attributes).to be_a(Attributes) }

    it "should allow setting an attribute through #set_attribute" do
      tag.set_attribute :autocomplete, 'off'
      tag.set_attribute 'placeholder', '(test)'
      expect(tag.attributes).to eq('autocomplete' => 'off', 'placeholder' => '(test)')
    end

    it "should allow getting an attribute through #get_attribute" do
      tag.set_attribute :autocomplete, 'off'
      expect(tag.get_attribute(:autocomplete)).to eql('off')
      expect(tag.get_attribute('autocomplete')).to eql('off')
    end

    it "should allow setting an attribute through an indexer" do
      tag[:autocomplete] = 'off'
      tag['placeholder'] = '(test)'
      expect(tag.attributes).to eq('autocomplete' => 'off', 'placeholder' => '(test)')
    end

    it "should allow getting an attribute through an indexer" do
      tag[:autocomplete] = 'off'
      expect(tag[:autocomplete]).to eql('off')
      expect(tag['autocomplete']).to eql('off')
    end

    it "should check whether an attribute is set through has_attribute?" do
      tag[:autocomplete] = 'off'
      expect(tag).to have_attribute(:autocomplete)
      expect(tag).to have_attribute('autocomplete')
      expect(tag).not_to have_attribute(:placeholder)
    end

    describe "attribute accessors" do

      let(:tag_class) do
        Class.new(Input) do
          attribute :value
          attribute :autocomplete, boolean: true
        end
      end
      let(:tag) { tag_class.new }

      it "should allow access to the :value attribute through a method" do
        tag.value = 'Test'
        expect(tag[:value]).to eql('Test')

        tag[:value] = 'Test'
        expect(tag.value).to eql('Test')
      end

      it "should allow an attribute to be removed if set to nil" do
        tag[:value] = 'Test'
        tag.value = nil
        expect(tag).not_to have_attribute(:value)
      end

      it "should allow access to the boolean attribute :autocomplete through a method" do
        tag.autocomplete = true
        expect(tag.autocomplete).to be_truthy
        expect(tag[:autocomplete]).to eql('autocomplete')

        tag.autocomplete = double(:something_trueish)
        expect(tag.autocomplete).to be_truthy
        expect(tag[:autocomplete]).to eql('autocomplete')

        tag.autocomplete = false
        expect(tag.autocomplete).to be_falsey
        expect(tag[:autocomplete]).to be_nil
      end

      it "should use the value= method when passing in a value attribute to build!" do
        allow(tag.attributes).to receive(:[]=)

        value1 = double(:value); other1 = double(:other)
        expect(tag).to receive(:value=).with(value1)
        expect(tag.attributes).to receive(:[]=).with(:other, other1)
        tag.build! value: value1, other: other1

        value2 = double(:value); other2 = double(:other)
        expect(tag).to receive(:value=).with(value2)
        expect(tag.attributes).to receive(:[]=).with('other', other2)
        tag.build! 'value' => value2, 'other' => other2
      end

      it "should not accidentally set the content this way" do
        content = 'My Content'
        expect(tag).not_to receive(:content=)
        tag.build! content: content
        expect(tag.attributes[:content]).to eql('My Content')
      end

      it "should not accidentally invoke a helper method" do
        helpers = double(:value= => nil)
        allow(tag).to receive(:helpers).and_return(helpers)
        expect(helpers).not_to receive(:value=)

        tag.build! value: 'My Value'
        expect(tag.attributes[:value]).to eql('My Value')
      end

    end

  ######
  # ID, classes & style

    describe '#generate_id' do
      it "should generate an ID for the tag using its object_id" do
        tag.generate_id!
        expect(tag.id).to eql(tag.object_id.to_s)
        expect(tag[:id]).to eql(tag.object_id.to_s)
      end
    end

    describe '#classes' do
      it "should be the same as the :class attribute" do
        expect(tag.classes).to be(tag[:class])
      end
    end

    describe '#classes=' do
      it "should replace the class attribute" do
        expect(tag.attributes).to receive(:[]=).with(:class, 'one')
        tag.classes = 'one'
      end
    end

    describe '#add_class' do
      it "should add classes" do
        tag.add_class 'one'
        expect(tag.classes.to_a).to eql(['one'])
        tag.add_class 'two three'
        expect(tag.classes.to_a).to eql(['one', 'two', 'three'])
      end
    end

    describe '#remove_class' do
      it "should remove classes" do
        tag.classes = 'one two three'
        expect(tag.classes.to_a).to eql(['one', 'two', 'three'])
        tag.remove_class 'two three'
        expect(tag.classes.to_a).to eql(['one'])
      end
    end

    describe '#has_class?' do
      it "should check whether the given class is present" do
        tag.classes = 'one two three'
        expect(tag).to have_class('one')
        expect(tag).not_to have_class('four')
      end

      it "should check whether *all* given classes is present" do
        tag.classes = 'one two three'
        expect(tag).to have_class('one two')
        expect(tag).not_to have_class('two four')
      end
    end

    describe '#style' do
      it "should be the same as the :style attribute" do
        expect(tag.style).to be(tag[:style])
      end
    end
    describe '#style=' do
      it "should set the style attribute" do
        tag.style = 'float: left;'
        expect(tag[:style]).to eql('float' => 'left')
      end
    end

  ## Rendering is exemplified in the integration HTML spec.

  ######
  # Inspection

    it "should provide a terse description when using #inspect" do
      table = Arbre::Html::Table.new
      expect(table.inspect).to eql('<table>')

      table.id = 'test'
      expect(table.inspect).to eql('<table#test>')

      table.classes << 'one' << 'two'
      expect(table.inspect).to eql('<table#test.one.two>')

      table.id = nil
      expect(table.inspect).to eql('<table.one.two>')

      input = Arbre::Html::Input.new
      input.type = 'text'
      expect(input.inspect).to eql('<input[type=text]>')
    end

    it "should append the class name if this is different from the tag name" do
      klass = Class.new(Html::Tag) do
        def tag_name
          'table'
        end
        def self.name
          'Datagrid'
        end
      end

      expect(klass.new.inspect).to eql('<table(Datagrid)>')
    end

end
