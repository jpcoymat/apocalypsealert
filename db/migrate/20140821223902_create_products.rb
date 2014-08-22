class CreateProducts < ActiveRecord::Migration
  def change
    create_table :products do |t|
      t.string :name
      t.string :code
      t.string :category
      t.integer :organization_id

      t.timestamps
    end
  end
end
