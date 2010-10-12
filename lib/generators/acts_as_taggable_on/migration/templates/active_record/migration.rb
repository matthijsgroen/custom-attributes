class ActsAsTaggableOnMigration < ActiveRecord::Migration
  def self.up
    create_table :custom_attributes do |t|
			# label
      t.string :field_name
      t.string :field_label

      # value type
      t.string :value_type
			
			# fields for value storage
      t.string :text_value
      t.datetime :date_time_value
      t.integer :number_value
      t.float :float_value

			# sorting
      t.integer :position
			# link to object
      t.references :item, :polymorphic => true

      t.timestamps
    end

    add_index :custom_attributes, :value_type
    add_index :custom_attributes, [:item_id, :item_type]
  end

  def self.down
    drop_table :custom_attributes
  end
end
