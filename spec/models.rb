class Person < ActiveRecord::Base

  has_custom_attributes :telephone => :string, :email => :string do |fields|
    fields.telephone :work, :private, :mobile, :fax
    fields.email :work, :private
    fields.date :born_on, :wed_on, :died_on, :on_model => [:born_on]
  end

  def attribute_email(errors)

  end

end

class Product < ActiveRecord::Base

  has_custom_attributes :url => :string

  has_custom_attributes :size => :float do |fields|
    fields.size :width, :height, :depth
    fields.size :validate_all_with => :attribute_size_validation
    fields.url :details, :on_model => {:details => :details_url}
    fields.date :in_stock_since, :validate_with => lambda { |attribute| attribute.errors.add(:value, "must be after 2010") if attribute.value.to_date.year < 2010 }
  end

  def attribute_size_validation(attribute)
    attribute.errors.add(:value, "should be between 1 and 10") if attribute.value < 1 or attribute.value > 10
  end

end

class Location < ActiveRecord::Base

end
