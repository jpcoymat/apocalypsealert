class AddOrganizationIdToInventoryProjections < ActiveRecord::Migration
  def change
    add_column :inventory_projections, :organization_id, :integer
  end
end
