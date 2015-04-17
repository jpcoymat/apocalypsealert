class CreateBuyerGroups < ActiveRecord::Migration
  def change
    create_table :buyer_groups do |t|
      t.integer :organization_id
      t.string :name
      t.string :description

      t.timestamps
    end
  end
end
