class ActiveRecord::CustomAttributes::CustomAttributeModel < ActiveRecord::Base
  set_table_name "custom_attributes"

  belongs_to :item, :polymorphic => true
  validates :date_time_value, :presence => { :if => :date_storage? }

  private

  def date_storage?
    ["date_time", "date", "time"].include? value_type
  end

end
