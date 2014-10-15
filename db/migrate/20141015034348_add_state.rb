class AddState < ActiveRecord::Migration


  def change
    add_column :shipment_lines, :status, :integer, default: 0
    add_column :order_lines, :status, :integer, default: 0
  end
end
