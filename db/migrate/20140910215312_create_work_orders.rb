class CreateWorkOrders < ActiveRecord::Migration
  def change
    create_table :work_orders do |t|
      t.string :work_order_number
      t.integer :product_id
      t.integer :location_id
      t.date :production_date
      t.integer :quantity
      t.integer :organization_id

      t.timestamps
    end
  end
end
