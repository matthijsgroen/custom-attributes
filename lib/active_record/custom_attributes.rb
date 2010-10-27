module ActiveRecord

  module CustomAttributes

    CUSTOM_ATTRIBUTE_TYPES = %w(string integer boolean date time datetime float)

    def self.included(base) # :nodoc:
      base.extend ClassMethods
    end

    module ClassMethods

      def has_custom_attributes?
        false
      end

      def has_custom_attributes(extra_field_types = {}, &block)
        field_types = extra_field_types
        field_types = self.defined_custom_field_types.merge(extra_field_types) if has_custom_attributes?

        field_definitions = CustomAttributeDefinitionHelper.new field_types
        yield field_definitions if block_given?
        defined_custom_attributes = field_definitions.defined_attributes
        defined_custom_validations = field_definitions.defined_validations

        if has_custom_attributes?
          write_inheritable_attribute(:defined_custom_attributes, self.defined_custom_attributes.deep_merge(defined_custom_attributes))
          write_inheritable_attribute(:defined_custom_validations, self.defined_custom_validations.deep_merge(defined_custom_validations))
          write_inheritable_attribute(:defined_custom_field_types, field_types)
        else
          write_inheritable_attribute(:defined_custom_attributes, defined_custom_attributes)
          class_inheritable_reader(:defined_custom_attributes)

          write_inheritable_attribute(:defined_custom_validations, defined_custom_validations)
          class_inheritable_reader(:defined_custom_validations)

          write_inheritable_attribute(:defined_custom_field_types, extra_field_types)
          class_inheritable_reader(:defined_custom_field_types)

          class_eval do
            def self.has_custom_attributes?
              true
            end

            include ActiveRecord::CustomAttributes::Core
          end
        end
      end

    end

    class CustomAttributeDefinitionHelper

      def initialize extra_field_types
        @defined_attributes = {}
        @defined_validations = {}

        extra_field_types.each do |key, value|
          class_eval do
            define_method key do |*args|
              define_field(key, *args)
            end
          end
        end
      end

      ActiveRecord::CustomAttributes::CUSTOM_ATTRIBUTE_TYPES.each do |type|
        define_method type do |*args|
          define_field(type.to_sym, *args)
        end
      end

      attr_reader :defined_attributes, :defined_validations

      private

      def define_field(type, *args)
        options = args.extract_options!
        options.assert_valid_keys(:on_model, :validate_with, :validate_all_with)

        attributes_on_model = {}
        if options[:on_model].is_a? Array
          options[:on_model].each do |attribute|
            attributes_on_model[attribute] = attribute
          end
        elsif options[:on_model].is_a? Hash
          attributes_on_model = options[:on_model]
        end
        if options[:validate_all_with]
          @defined_validations[type] = options[:validate_all_with]
        end

        args.each do |field|
          field = field.to_sym
          @defined_attributes[type] ||= {}
          @defined_attributes[type][field] = {
                  :type => type,
                  :name => field,
                  :on_model => attributes_on_model[field] || false,
                  :validate_with => options[:validate_with] || nil
          }
        end
      end

    end

    module Core

      def self.included(base)
        base.send :include, ActiveRecord::CustomAttributes::Core::InstanceMethods
        base.extend ActiveRecord::CustomAttributes::Core::ClassMethods
        base.has_many :external_custom_attributes, :class_name => "ActiveRecord::CustomAttributes::CustomAttributeModel",
                      :as => :item, :dependent => :destroy

        base.before_save :cache_custom_attributes
        base.after_save :save_custom_attributes
        base.validate :validate_custom_attributes
      end

      module ClassMethods

      end

      module InstanceMethods

        def custom_attributes
          @custom_attributes ||= ActiveRecord::CustomAttributes::CustomAttributeList.new(self)
        end

        def custom_attributes= post_data
          custom_attributes.set_post_data post_data
        end

        private

        def cache_custom_attributes
          custom_attributes.update_cache
        end

        def save_custom_attributes
          custom_attributes.save
        end

        def validate_custom_attributes
          custom_attributes.validate(errors)
        end

      end

    end

  end

end
