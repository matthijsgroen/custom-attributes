class ActiveRecord::CustomAttributes::CustomAttribute

  def initialize(item_list, main_model, attribute_model)
    @main_model = main_model
    @item_list = item_list
    @attribute_model = attribute_model
    @marked_for_destruction = false
    @errors = ActiveModel::Errors.new(self)
    load if @attribute_model
  end

  [:type, :value, :label, :internal_label].each do |property|
    attr_accessor property

    define_method "#{property}_with_activation=" do |new_value|
      @marked_for_destruction = false
      send("#{property}_without_activation=".to_sym, new_value)
    end
    alias_method_chain "#{property}=".to_sym, :activation
  end

  def rename_to new_name
    item_list.rename_label_of self, new_name
  end

  def mark_for_destruction
    @marked_for_destruction = true
  end

  def marked_for_destruction?
    @marked_for_destruction
  end

  def validate
    errors.clear
    return if marked_for_destruction?
    assign_model_value
    unless attribute_model.valid?
      attribute_model.errors.each do |attribute, message|
        errors.add :value, message
      end
    end
    validations = item_list.get_custom_validations_for type, internal_label
    validations.each do |validator|
      main_model.send(validator, self) if validator.is_a? Symbol
      validator.call(self) if validator.is_a? Proc
    end
  end

  def valid?
    errors.empty?
  end

  def save
    attribute_model.destroy and return if marked_for_destruction?
    assign_model_value
    attribute_model.save
  end

  attr_reader :errors

  private

  attr_reader :main_model, :item_list

  FIELD_MAPPING = {
          :text => :text,
          :string => :text,
          :float => :float,
          :number => :number,
          :boolean => :number,
          :date_time => :date_time,
          :date => :date_time,
          :time => :date_time
  }

  def assign_model_value
    attribute_model.value_type = type.to_s
    attribute_model.field_name = internal_label.to_s
    attribute_model.field_label = label
    write_value = item_list.supported_attribute_types[type]
    field = FIELD_MAPPING[write_value]

    converted_value = value
    converted_value = value ? 1 : 0 if write_value == :boolean

    ([:text, :date_time, :number, :float] - [field]).each { |value_field| attribute_model.send("#{value_field}_value=", nil) }
    attribute_model.send("#{field}_value=", converted_value)
  end

  def load
    self.type = attribute_model.value_type.to_sym
    self.internal_label = attribute_model.field_name.to_sym
    self.label = attribute_model.field_label

    read_value = item_list.supported_attribute_types[self.type]
    field = FIELD_MAPPING[read_value]
    value = attribute_model.send("#{field}_value")
    value = value == 0 ? false : true if read_value == :boolean
    #puts "#{self.type} => #{read_value} = (#{field}) #{value} - #{self.label} (#{self.internal_label})"
    self.value = value
  end

  def attribute_model
    @attribute_model ||= main_model.external_custom_attributes.build
  end

end