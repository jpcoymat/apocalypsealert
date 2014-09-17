class AddOrderType < ActiveRecord::Migration
  def change
    add_column :order_lines, :order_type, :string
  end
end
