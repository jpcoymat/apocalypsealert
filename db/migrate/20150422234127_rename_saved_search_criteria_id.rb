class RenameSavedSearchCriteriaId < ActiveRecord::Migration
  def change
    rename_column :users, :saved_search_criteria_id, :saved_search_criterium_id
  end
end
