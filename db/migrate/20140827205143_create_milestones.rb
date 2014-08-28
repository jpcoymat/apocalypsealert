class CreateMilestones < ActiveRecord::Migration
  def change
    create_table :milestones do |t|
      t.string :associated_object_type
      t.integer :associated_object_id
      t.string :milestone_type
      t.string :reason_code
      t.string :city
      t.string :country
      t.decimal :quantity
      t.integer :customer_organization_id
      t.integer :create_organization_id
      t.integer :create_user_id

      t.timestamps
    end
  end
end
