class Person < ActiveRecord::Base

  has_custom_attributes :telephone => :string, :email => :string do |fields|
    fields.telephone :work, :private, :mobile, :fax
    fields.email :work, :private
    fields.date :born_on, :wed_on, :died_on, :on_model => [ :born_on ]
  end

end

class Product < ActiveRecord::Base

  has_custom_attributes :size => :float do |fields|
    fields.size :width, :height, :depth
  end

end

class Location < ActiveRecord::Base

end
