class AddIsActiveToWorkOrders < ActiveRecord::Migration
  def change
    add_column :work_orders, :is_active, :boolean
  end
end
