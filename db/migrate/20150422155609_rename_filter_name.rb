class RenameFilterName < ActiveRecord::Migration
  def change
    rename_column :saved_search_criteria, :filter_name, :page
  end
end
