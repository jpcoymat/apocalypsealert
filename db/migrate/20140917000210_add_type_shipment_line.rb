class AddTypeShipmentLine < ActiveRecord::Migration
  def change
    add_column :shipment_lines, :shipment_type, :string
  end
end
