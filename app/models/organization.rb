class Organization < ActiveRecord::Base

  has_many :locations
  has_many :location_groups
  has_many :products
  has_many :users


  def order_lines
    @order_lines = OrderLine.where("customer_organization_id = ? or supplier_organization_id = ?", self.id, self.id)
    @order_lines
  end

  def shipment_lines
    @shipment_lines = ShipmentLine.where("carrier_organization_id = ? or forwarder_organization_id = ? or customer_organization_id = ?", self.id, self.id, self.id)
    @shipment_lines
  end

  def deleteable?
    if locations.empty? and location_groups.empty? and products.empty? and users.empty?
      order_lines = OrderLine.where("customer_organization_id = #{self.id} or supplier_organization_id = #{self.id}")
      if order_lines.empty?
        shipment_lines = ShipmentLine.where("carrier_organization_id = #{self.id} or forwarder_organization_id = #{self.id} or customer_organization_id = #{self.id}")
        if shipment_lines.empty?
          return true
        else
          return false
        end 
      else
        return false
      end
    else
      return false
    end
  end

end
