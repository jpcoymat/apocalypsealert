class CreateShipmentLines < ActiveRecord::Migration
  def change
    create_table :shipment_lines do |t|
      t.string :shipment_line_number
      t.decimal :quantity
      t.date :eta
      t.date :etd
      t.integer :origin_location_id
      t.integer :destination_location_id
      t.integer :order_line_id

      t.timestamps
    end
  end
end
