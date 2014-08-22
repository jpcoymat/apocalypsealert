class AddCustomerOrgIdToMovementsources < ActiveRecord::Migration

  def change
    add_column :shipment_lines, :customer_organization_id, :integer
    add_column :order_lines, :customer_organization_id, :integer

  end
end
