class ChangeWorkOrderAttributes < ActiveRecord::Migration
  def change
    rename_column :work_orders, :production_date, :production_begin_date
    add_column :work_orders, :production_end_date, :date
  end
end
