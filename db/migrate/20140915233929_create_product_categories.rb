class CreateProductCategories < ActiveRecord::Migration
  def change
    create_table :product_categories do |t|
      t.string :description
      t.string :name
      t.integer :organization_id
      t.timestamps
    end
  end
end
