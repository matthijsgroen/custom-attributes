module Formtastic
  module CustomAttributes

    def custom_attribute_inputs(include_associations = {})
      @supported_attribute_types     ||= {}
      @supported_attribute_templates ||= []

      has_custom = false
      if @object.respond_to? :custom_attributes
        @object.custom_attributes.defined_attribute_types.each do |attribute_type|
          if attribute_type == :custom_attributes
            has_custom = true
          else
            add_custom_attribute_template_for attribute_type
          end
        end
      end

      # Add other custom fields like addresses
      include_associations.each do |association, association_options|
        add_custom_association_attribute_template_for association, association_options
      end

      add_custom_attribute_template_for :custom if @object.respond_to? :custom_attributes and has_custom

      content_tag(:div, Formtastic::Util.html_safe(
              @supported_attribute_templates.join +
                      add_custom_attribute_input

      ), :class => "custom-attributes")
    end

    private

    def add_custom_attribute_template_for(attribute_type)
      storage_type = @object.custom_attributes.supported_attribute_types[attribute_type]
      i18n_scope = [:activerecord, :custom_attributes, @object.class.model_name.underscore.to_sym]

      value_fields = @object.custom_attributes.attributes_of_type(attribute_type).collect do |attribute|
        custom_field_input(attribute_type, [attribute_type, storage_type], attribute.label, attribute.value)
      end
      field_template = custom_field_input(attribute_type, [attribute_type, storage_type], "", nil, :template => true)

      attribute_human_name = ::I18n.t(:attribute_name,
              :count => 1,
              :scope => i18n_scope + [attribute_type]).capitalize

      value_fields << content_tag(:li,
              template.link_to(Formtastic::Util.html_safe(attribute_human_name),
                      "#add-#{attribute_type}",
                      :class => "add-link",
                      :title => ::I18n.t(:add, :scope => :default_actions, :model => attribute_human_name),
                      :'data-attribute-type' => attribute_type
              ) << field_template << label_data_list_for(attribute_type, @object.custom_attributes.defined_labels_for(attribute_type)),
              :class => "field-addition"
      )

      @supported_attribute_types[attribute_type] = attribute_human_name
      @supported_attribute_templates << content_tag(
              :fieldset, content_tag(
                      :legend, self.label(:custom_attributes, :label => ::I18n.t(:attribute_name, :count => 2,
                              :scope => i18n_scope + [attribute_type]).capitalize), :class => 'label'
              ) << content_tag(:ol, Formtastic::Util.html_safe(value_fields.join)),
                      :'data-attribute-type' => attribute_type
      )
    end

    def add_custom_association_attribute_template_for(association_name, options)
      association = @object.class.reflect_on_association(association_name)
      storage_type = association.klass.model_name.underscore.to_sym

      value_fields = @object.send(association_name).collect do |item|
        custom_field_input(storage_type, [storage_type], item.name, item)
      end
      field_template = custom_field_input(storage_type, [storage_type], "", nil, :template => true)

      attribute_human_name = association.klass.model_name.human
      value_fields << content_tag(:li,
              template.link_to(Formtastic::Util.html_safe(attribute_human_name),
                      "#add-#{storage_type}",
                      :class => "add-link",
                      :title => ::I18n.t(:create_custom_attribute, :scope => [:formtastic, :actions], :attribute => attribute_human_name),
                      :'data-attribute-type' => storage_type
              ) << field_template << label_data_list_for(storage_type, options[:labels]),
              :class => "field-addition"
      )

      @supported_attribute_types[storage_type] = attribute_human_name
      @supported_attribute_templates << content_tag(
              :fieldset, content_tag(
                      :legend, self.label(:custom_attributes, :label => association.klass.model_name.human(:count => 2)), :class => 'label'
              ) << content_tag(:ol, Formtastic::Util.html_safe(value_fields.join)),
                      :'data-attribute-type' => storage_type
      )
    end

    def label_data_list_for(attribute_type, labels)
      options = labels.collect do |label|
        content_tag(:option, "", :value => label)
      end

      content_tag(:datalist,
              Formtastic::Util.html_safe(
                      "<!--[if !IE]><!--><select><!--<![endif]-->" +
                              options.join +
                              "<!--[if !IE]><!--></select><!--<![endif]-->"),
              :id => "#{attribute_type}-label-suggestions"
      )
    end

    def add_custom_attribute_input
      label_name = ::I18n.t(:add_attribute, :scope => [:activerecord, :custom_attributes, :standard])
      field_set_and_list_wrapping_for_method(
              :custom_attributes,
                      {:label => false},
                      content_tag(:li,
                              template.label_tag("add_custom_attribute_type", label_name) <<
                                      template.select_tag("add_custom_attribute_type", template.options_for_select(
                                              [[label_name, "_choose"]] + @supported_attribute_types.collect { |key, value| [value, key] }
                                      )), :class => "add-custom-attribute")
      )

    end

    def field_name_for(attribute_type, field_type)
      "#{@object.class.model_name.underscore}[custom_attributes][#{attribute_type}][#{field_type}][]"
    end

    def custom_field_input(attribute_type, field_method_priority, label, value, options = {})
      label_name  = field_name_for attribute_type, "label"
      label_field = template.text_field_tag(label_name, label, :list => "#{attribute_type}-label-suggestions", :autocomplete => "off")

      input_field_method = field_method_priority.collect { |m| "custom_#{m}_input".to_sym }.find { |m| self.respond_to? m, true }
      input_field = send(input_field_method, attribute_type, value, options)

      content_tag(options[:template] ? :div : :li,
              Formtastic::Util.html_safe(content_tag(:div, label_field, :class => "label") <<
                      input_field) << inline_hints_for(field_method_priority.first, options),
              :class => options[:template] ? "template" : "value optional #{attribute_type}"
      )
    end

    def custom_attribute_delete_link(attribute_human_name)
      label = ::I18n.t(:destroy_custom_attribute, :scope => [:formtastic, :actions], :attribute => attribute_human_name)
      escape_html_entities(" ") + template.link_to(escape_html_entities(label), "#remove", :class => "delete-link")
    end

    ## Field addition support

    def custom_string_input(attribute_type, value, options = {})
      default_custom_field_handler(:text_field_tag, attribute_type, value)
    end

    def custom_email_input(attribute_type, value, options = {})
      default_custom_field_handler(:email_field_tag, attribute_type, value)
    end

    def custom_url_input(attribute_type, value, options = {})
      default_custom_field_handler(:url_field_tag, attribute_type, value)
    end

    def default_custom_field_handler(method, attribute_type, value)
      i18n_scope = [:activerecord, :custom_attributes, @object.class.model_name.underscore.to_sym]
      attribute_human_name = ::I18n.t(:attribute_name, :count => 1, :scope => i18n_scope + [attribute_type]).capitalize
      template.send(method, field_name_for(attribute_type, "value"), value) <<
              custom_attribute_delete_link(attribute_human_name)
    end

    delegate :content_tag, :to => :template

  end

end