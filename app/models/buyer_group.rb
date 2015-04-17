class BuyerGroup < ActiveRecord::Base

  validates   :name, :organization_id, presence: true
  
  validates   :name, uniqueness: {scope: :organization_id}
  
  belongs_to  :organization
  has_many    :order_lines 

end
