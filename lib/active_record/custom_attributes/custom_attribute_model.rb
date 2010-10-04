class ActiveRecord::CustomAttributes::CustomAttributeModel < ActiveRecord::Base
  set_table_name "custom_attributes"

  belongs_to :item, :polymorphic => true
end
