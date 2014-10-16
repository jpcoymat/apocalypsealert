class CreateOrderItineraries < ActiveRecord::Migration
  def change
    create_table :order_itineraries do |t|
      t.integer :order_line_id
      t.integer :shipment_line_id
      t.integer :leg_number

      t.timestamps
    end
  end
end
