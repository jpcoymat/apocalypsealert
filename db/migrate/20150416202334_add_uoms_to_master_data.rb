class AddUomsToMasterData < ActiveRecord::Migration

  def change
    add_column :order_lines,      :total_cost,    :decimal
    add_column :shipment_lines,   :total_cost,    :decimal
    add_column :shipment_lines,   :total_weight,  :decimal
    add_column :shipment_lines,   :total_volume,  :decimal
    add_column :products,         :unit_cost,    :decimal
    add_column :products,         :unit_weight,  :decimal
    add_column :products,         :unit_volume,  :decimal
    
  end

end
