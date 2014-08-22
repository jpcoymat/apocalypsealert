class CreateScvExceptions < ActiveRecord::Migration
  def change
    create_table :scv_exceptions do |t|
      t.string :type
      t.integer :priority
      t.integer :status
      t.references :affected_object, polymorphic: true
      t.string :affected_object_quantity_type
      t.decimal :affected_object_quantity
      t.string :affected_object_date_type
      t.date   :affected_object_date
      t.references :cause_object, polymorphic: true
      t.string :cause_object_quantity_type
      t.decimal :cause_object_quantity
      t.string :cause_object_date_type
      t.date :cause_object_date
      t.timestamps
    end
  end
end
