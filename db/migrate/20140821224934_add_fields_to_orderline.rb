class AddFieldsToOrderline < ActiveRecord::Migration
  def change
    add_column :order_lines, :supplier_organization_id, :integer

  end
end
