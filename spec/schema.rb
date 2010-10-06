ActiveRecord::Schema.define :version => 0 do
  create_table :custom_attributes, :force => true do |t|
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

  create_table "people", :force => true do |t|
    t.string :name
    t.date :born_on
    t.string :email
  end

  create_table "products", :force => true do |t|
    t.string :name
    t.float :width
    t.float :height
    t.string :details_url
  end

  create_table "locations", :force => true do |t|
    t.string :name
  end

end
