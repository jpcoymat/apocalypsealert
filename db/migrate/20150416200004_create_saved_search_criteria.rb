class CreateSavedSearchCriteria < ActiveRecord::Migration
  def change
    create_table :saved_search_criteria do |t|
      t.string :name
      t.string :filter_name
      t.text :parameters

      t.timestamps
    end
  end
end
