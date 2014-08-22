class AddFieldsToShipmentLine < ActiveRecord::Migration
  def change
    add_column :shipment_lines, :mode, :string
    add_column :shipment_lines, :carrier_organization_id, :integer
    add_column :shipment_lines, :forwarder_organization_id, :integer
  end
end
