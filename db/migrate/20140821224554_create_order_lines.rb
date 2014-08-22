class CreateOrderLines < ActiveRecord::Migration
  def change
    create_table :order_lines do |t|
      t.string :order_line_number
      t.decimal :quantity
      t.date :eta
      t.date :etd
      t.integer :origin_location_id
      t.integer :destination_location_id

      t.timestamps
    end
  end
end
