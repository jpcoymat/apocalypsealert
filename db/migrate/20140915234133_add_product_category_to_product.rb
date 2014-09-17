class AddProductCategoryToProduct < ActiveRecord::Migration
  def change
    remove_column :products, :category
    add_column :products, :product_category_id, :integer
  end
end
