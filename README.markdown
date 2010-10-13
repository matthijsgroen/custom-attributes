Custom Attributes
=================

Makes it easy to extend models with custom attributes. Think about adding telephone numbers to people,
or weight and size measurements to products.

Most of these fields can be used purely dynamic and objects could have multiples of them (think telephone numbers, or email
addresses)

This code is *NOT* production ready yet!

TODO
====
- Make Formtastic extension better
- Supply specs for the formtastic part
- Make custom extensions work as nested forms (accept_attributes_for stuff)


Contents of the package
=======================

* Extension for ActiveRecord
* Extension for Formtastic (including jQuery widget)
* Extension for Cucumber for integration testing

Usage
=====
ActiveRecord will be extended automatically

Formtastic needs to be extended manually, like:

    Formtastic::SemanticFormBuilder.send(:include, Formtastic::CustomAttributes)

Or when using a custom Form builder, just

    include ::Formtastic::CustomAttributes

in your custom form builder

In the public folder are CSS and jQuery files for building a user interface

Example
=======

    # model
    class Location < ActiveRecord::Base

      has_custom_attributes :url => :string, :telephone => :string, :email => :string, :custom => :string do |fields|
        fields.telephone :common, :help_desk, :sales, :fax
        fields.email :common, :sales, :help_desk
        fields.url :website
      end

    end

    # view (haml)

    = semantic_form_for resource do |form|
      = form.inputs "General", :name
      = form.custom_attribute_inputs
      = form.buttons

I18n
====

    nl:
      activerecord:
        custom_attributes:
          location:
            attribute_names:
              telephone:
                one: "telefoonnummer"
                other: "telefoonnummers"
              url:
                one: "website"
                other: "websites"
              email:
                one: "e-mail adres"
                other: "e-mail adressen"
              custom:
                one: "ander attribuut"
                other: "andere attributen"

            telephone:
              common: "Algemeen"
              help_desk: "Helpdesk"
              sales: "Verkoop afdeling"
              fax: "Fax"

            email:
              common: "Algemeen"
              help_desk: "Helpdesk"
              sales: "Verkoop afdeling"

		formtastic:
		  actions:
		    add_custom_attribute: "Attribuut toevoegen"
		    create_custom_attribute: "%{attribute} toevoegen"
		    destroy_custom_attribute: "%{attribute} verwijderen"

		  hints:
		    location:
		      telephone: "+31 (0) 12 3456 789"

