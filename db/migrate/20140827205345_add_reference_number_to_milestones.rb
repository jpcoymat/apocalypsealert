class AddReferenceNumberToMilestones < ActiveRecord::Migration
  def change
    add_column :milestones, :reference_number, :string
  end
end
