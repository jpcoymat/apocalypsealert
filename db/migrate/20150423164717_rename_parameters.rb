class RenameParameters < ActiveRecord::Migration
  def change
    rename_column :saved_search_criteria, :parameters, :search_parameters
  end
end
