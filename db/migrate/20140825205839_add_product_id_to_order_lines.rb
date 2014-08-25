class AddProductIdToOrderLines < ActiveRecord::Migration
  def change
    add_column :order_lines, :product_id, :integer
  end
end
