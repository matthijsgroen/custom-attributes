require "active_record"
require "active_support"

$LOAD_PATH.unshift(File.dirname(__FILE__))

require "active_record/custom_attributes"
require "active_record/custom_attributes/custom_attribute"
require "active_record/custom_attributes/custom_attribute_list"
require "active_record/custom_attributes/custom_attribute_model"

require "formtastic/custom_attributes"

$LOAD_PATH.shift

if defined?(ActiveRecord::Base)
  ActiveRecord::Base.send :include, ActiveRecord::CustomAttributes
end
