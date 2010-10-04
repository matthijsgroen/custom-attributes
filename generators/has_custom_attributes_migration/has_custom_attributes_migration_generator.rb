class HasCustomAttributesMigrationGenerator < Rails::Generator::Base 
  def manifest 
    record do |m| 
      m.migration_template 'migration.rb', 'db/migrate', :migration_file_name => "has_custom_attributes_migration"
    end
  end
end
