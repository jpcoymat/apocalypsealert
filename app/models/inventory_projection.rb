class InventoryProjection < ActiveRecord::Base

  belongs_to :location
  belongs_to :product

  validates :location_id, :product_id, :projected_for, :available_quantity, presence: true
  

end
