class CreateInventoryProjections < ActiveRecord::Migration
  def change
    create_table :inventory_projections do |t|
      t.integer :location_id
      t.integer :product_id
      t.date :projected_for
      t.decimal :available_quantity

      t.timestamps
    end
  end
end
