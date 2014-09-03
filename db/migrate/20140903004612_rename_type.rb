class RenameType < ActiveRecord::Migration
  def change
    rename_column :scv_exceptions, :type, :exception_type
  end
end
