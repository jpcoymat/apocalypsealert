class RemoveOrderLineIdFromShipmentLines < ActiveRecord::Migration

  def change
    remove_column :shipment_lines, :order_line_id
  end
end
