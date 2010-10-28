# Generated by jeweler
# DO NOT EDIT THIS FILE DIRECTLY
# Instead, edit Jeweler::Tasks in Rakefile, and run the gemspec command
# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{custom-attributes}
  s.version = "0.2.20"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Matthijs Groen"]
  s.date = %q{2010-10-27}
  s.description = %q{Easy management of extra model attributes. Can store fields in the model if provided}
  s.email = %q{matthijs.groen@gmail.com}
  s.extra_rdoc_files = [
    "README.markdown"
  ]
  s.files = [
    "Gemfile",
     "Gemfile.lock",
     "MIT-LICENSE",
     "README.markdown",
     "Rakefile",
     "VERSION",
     "generators/has_custom_attributes_migration/has_custom_attributes_migration_generator.rb",
     "generators/has_custom_attributes_migration/templates/migration.rb",
     "lib/active_record/custom_attributes.rb",
     "lib/active_record/custom_attributes/custom_attribute.rb",
     "lib/active_record/custom_attributes/custom_attribute_list.rb",
     "lib/active_record/custom_attributes/custom_attribute_model.rb",
     "lib/custom-attributes.rb",
     "lib/formtastic/custom_attributes.rb",
     "lib/generators/custom_attributes/migration/migration_generator.rb",
     "lib/generators/custom_attributes/migration/templates/active_record/migration.rb",
     "rails/init.rb",
     "spec/custom_attributes/custom_attributes.sqlite3",
     "spec/custom_attributes/has_custom_attributes_spec.rb",
     "spec/database.yml",
     "spec/database.yml.sample",
     "spec/models.rb",
     "spec/schema.rb",
     "spec/spec_helper.rb"
  ]
  s.homepage = %q{http://github.com/matthijsgroen/custom-attributes}
  s.rdoc_options = ["--charset=UTF-8"]
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.7}
  s.summary = %q{Management for custom model attributes.}
  s.test_files = [
    "spec/spec_helper.rb",
     "spec/models.rb",
     "spec/custom_attributes/has_custom_attributes_spec.rb",
     "spec/schema.rb"
  ]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
    else
    end
  else
  end
end

