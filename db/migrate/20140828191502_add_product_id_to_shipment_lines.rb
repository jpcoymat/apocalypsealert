class AddProductIdToShipmentLines < ActiveRecord::Migration
  def change
    add_column :shipment_lines, :product_id, :integer
  end
end
