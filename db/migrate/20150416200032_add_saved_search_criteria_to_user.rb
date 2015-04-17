class AddSavedSearchCriteriaToUser < ActiveRecord::Migration

  def change
    add_column :users, :saved_search_criteria_id, :integer
  end
end
