require File.expand_path('../../spec_helper', __FILE__)

describe "Model without custom attributes" do

  subject { Location }

  it { should_not have_custom_attributes }

end

describe "Model with custom attributes" do

  subject { Person }

  it { should have_custom_attributes }

end

describe "Custom attributes of a person" do
  before(:each) do
    clean_database!

    I18n.backend.store_translations :'nl', {
      :activerecord => { :custom_attributes => { :person => { :telephone => { :private => "Prive" }}}}
    }
    I18n.default_locale = 'nl'

    @person = Person.new
  end

  subject { @person.custom_attributes }

  it { should respond_to :add_telephone }
  it { should_not respond_to :add_size }

  it "should add custom field values" do
    @person.custom_attributes.add_telephone "Prive", "06 28 61 06 28"
    fields = @person.custom_attributes.telephone_attributes
    fields.should have(1).item
    fields[0].value.should == "06 28 61 06 28"
  end

  it "should cache fields locally" do
    @person.custom_attributes.add_date "Born on", Date.civil(1981, 5, 31)
    @person.save
    @person.born_on.should == Date.civil(1981,5, 31)
  end

  it "should store values in the database" do
    @person.custom_attributes.add_telephone "Prive", "06 28 61 06 28"
    @person.save

    loaded_person = Person.find @person.id
    fields = loaded_person.custom_attributes.telephone_attributes
    fields.should have(1).item
    fields[0].value.should == "06 28 61 06 28"
  end

  it "should load values by key" do
    @person.custom_attributes.add_telephone "Prive", "06 28 61 06 28"
    @person.save

    loaded_person = Person.find @person.id
    loaded_person.custom_attributes.telephone_value_of(:private).should == "06 28 61 06 28"
  end

  it "should rename labels" do
    @person.custom_attributes.add_telephone "Werk", "06 28 61 06 28"

    fields = @person.custom_attributes.telephone_attributes
    fields.should have(1).item
    fields[0].value.should == "06 28 61 06 28"
    fields[0].rename_to "Prive"

    @person.custom_attributes.telephone_value_of(:private).should == "06 28 61 06 28"
  end


end

describe "Custom attributes of a product" do
  before(:each) do
    clean_database!
    @product = Product.new
  end

  subject { @product.custom_attributes }

  it { should_not respond_to :add_telephone }
  it { should respond_to :add_size }

  it "should add custom field values" do
    @product.custom_attributes.add_size "Width", 5.60
    fields = @product.custom_attributes.size_attributes
    fields.should have(1).item
    fields[0].value.should == 5.60
  end

  it "should cache not fields locally" do
    @product.custom_attributes.add_size "Width", 5.60
    @product.save
    @product.width.should == nil
    @product.custom_attributes.size_value_of(:width).should == 5.60
  end

  it "should rename labels" do
    @product.custom_attributes.add_size "Width", 5.60

    fields = @product.custom_attributes.size_attributes
    fields.should have(1).item
    fields[0].value.should == 5.60
    fields[0].rename_to "Height"

    @product.custom_attributes.size_value_of(:width).should == nil
  end

end
