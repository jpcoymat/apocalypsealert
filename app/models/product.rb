class Product < ActiveRecord::Base
  belongs_to :organization
  validates :name, :code, :organization_id, presence: true
  validates_uniqueness_of :code, scope: :organization_id
  
  has_many :order_lines
  has_many :shipment_lines
  has_many :inventory_projections
  has_many :work_orders


  def deleteable?
    order_lines.empty? and shipment_lines.empty? and inventory_projections.empty?
  end
 
end
