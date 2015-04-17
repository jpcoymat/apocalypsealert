class AddBuyerIdToOrderLines < ActiveRecord::Migration

  def change
    add_column :order_lines, :buyer_group_id, :integer
  end

end
