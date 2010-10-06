class ActiveRecord::CustomAttributes::CustomAttributeList

  def initialize(record)
    @record = record
    @defined_attributes = @record.class.defined_custom_attributes
    @extra_attribute_types = @record.class.defined_custom_field_types
    define_attribute_methods
  end

  def add(type, label, value)
    type = type.to_sym
    internal_label = convert_to_internal_label(type, label)
    attribute = get_attribute(type, internal_label || label, true)
    attribute.value = value
  end

  def update_cache
    defined_attributes.each do |type, attributes|
      attributes.each do |name, options|
        if cache_attribute = options[:on_model]
          if attribute = get_attribute(type, name)
            record.send("#{cache_attribute}=", attribute.value)
          else
            record.send("#{cache_attribute}=", nil)
          end
        end
      end
    end
  end

  def save
    loaded_attributes.each(&:save)
  end

  def defined_attribute_types
    (extra_attribute_types.keys + defined_attributes.keys).uniq
  end

  def defined_labels_for type
    results = []
    (defined_attributes[type.to_sym] || {}).each do |key, options|
      results << human_label_for(type, key)
    end
    results
  end

  def supported_attribute_types
    return @supported_attribute_types if @supported_attribute_types
    standard_attribute_types = {}
    ActiveRecord::CustomAttributes::CUSTOM_ATTRIBUTE_TYPES.each { |t| standard_attribute_types[t.to_sym] = t.to_sym }
    @supported_attribute_types = (standard_attribute_types.merge extra_attribute_types)
  end

  def rename_label_of attribute, new_name
    internal_label = convert_to_internal_label(attribute.type, new_name)
    attribute.label = new_name
    attribute.internal_label = internal_label
  end

  private

  attr_reader :defined_attributes, :extra_attribute_types, :record

  def get_attribute(type, internal_label, auto_create = false)
    if internal_label.is_a? Symbol
      attribute = loaded_attributes.find { |a| a.type == type and a.internal_label.to_s == internal_label.to_s  }
    else
      attribute = loaded_attributes.find { |a| a.type == type and a.label == internal_label }
    end
    return attribute if attribute
    return nil unless auto_create

    new_attribute = ActiveRecord::CustomAttributes::CustomAttribute.new(self, record, nil)
    new_attribute.type = type.to_sym

    if internal_label.is_a? Symbol
      new_attribute.internal_label = internal_label
      new_attribute.label = human_label_for(type, internal_label)
    else
      new_attribute.internal_label = convert_to_internal_label(type, internal_label)
      new_attribute.label = internal_label
    end

    loaded_attributes << new_attribute
    new_attribute
  end

  def convert_to_internal_label(type, label)
    (defined_attributes[type] || {}).each do |name, options|
      return name if label == human_label_for(type, name)
    end
    nil
  end

  def human_label_for(type, internal_name)
    translate_scope = [:activerecord, :custom_attributes, record.class.name.underscore.to_sym, type.to_sym]
    defaults = [internal_name.to_s.underscore.gsub("_", " ").capitalize]
    I18n.t(internal_name, :scope => translate_scope, :default => defaults)
  end

  def get_attributes_of_type(type)
    loaded_attributes.select { |i| i.type == type }
  end

  def get_value_of(type, internal_label)
    found = get_attribute(type, internal_label)
    found.value if found
  end

  def loaded_attributes
    @loaded_attributes ||= record.external_custom_attributes.collect do |attribute_record|
      ActiveRecord::CustomAttributes::CustomAttribute.new(self, record, attribute_record)
    end
  end

  def define_attribute_methods
    supported_attribute_types.each do |key, value|
      class_eval do

        define_method "add_#{key}" do |label, value|
          add(key.to_sym, label, value)
        end

        define_method "#{key}_attributes" do
          get_attributes_of_type(key.to_sym)
        end

        define_method "#{key}_value_of" do |internal_name|
          get_value_of(key.to_sym, internal_name)
        end
      end
    end
  end

end