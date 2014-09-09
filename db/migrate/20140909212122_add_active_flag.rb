class AddActiveFlag < ActiveRecord::Migration
  def change
    add_column :order_lines, :is_active, :boolean
    add_column :shipment_lines, :is_active, :boolean

  end
end
