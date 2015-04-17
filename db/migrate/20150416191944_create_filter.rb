class CreateFilter < ActiveRecord::Migration

  def change
    create_table :filters do |t|
      t.string  :filter_name
      t.text    :filter_elements
      t.string  :page
    end
  end

end
