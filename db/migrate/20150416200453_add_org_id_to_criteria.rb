class AddOrgIdToCriteria < ActiveRecord::Migration

  def change
    add_column :saved_search_criteria, :organization_id, :integer
  end

end
