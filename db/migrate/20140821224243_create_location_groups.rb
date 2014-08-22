class CreateLocationGroups < ActiveRecord::Migration
  def change
    create_table :location_groups do |t|
      t.string :code
      t.string :name
      t.integer :organization_id

      t.timestamps
    end
  end
end
