class CreateLocations < ActiveRecord::Migration
  def change
    create_table :locations do |t|
      t.string :name
      t.string :code
      t.string :address
      t.string :city
      t.string :state_providence
      t.string :country
      t.string :postal_code
      t.decimal :latitude
      t.decimal :longitude
      t.integer :organization_id
      t.integer :location_group_id

      t.timestamps
    end
  end
end
