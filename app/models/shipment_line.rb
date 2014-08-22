class ShipmentLine < ActiveRecord::Base

  belongs_to :organization
  belongs_to :product
  belongs_to :order_line

  validates :shipment_line_number, :quantity, :organization_id, :product_id, :eta, :etd, presence: true
  validates_uniqueness_of :shipment_line_number, scope: :organization_id
  validate :origin_or_destination
  validate :parent_child_match
  validate :arrival_after_departure
  validate :different_locations

  def origin_location
    @origin_location = Location.where(id: self.origin_location_id).first
  end

  def destination_location
    @destination_location = Location.where(id: self.destination_location_id).first
  end

  def origin_location=(location)
    self.origin_location_id = location.try(:id)
  end

  def destination_location=(location)
    self.destination_location_id = location.try(:id)
  end

  protected

    def origin_or_destination
      if self.origin_location_id.nil? and self.destination_location_id.nil?
        errors.add(:base, "Origin and Destination cannot be both null")
      end
    end

    def arrival_after_departure
      if self.etd and self.eta
        if self.etd > self.eta
          errors.add(:base, "ETD cannot be greater than ETA")
        end
      end
    end

    def different_locations
      if origin_location == destination_location
        errors.add(:base, "Origin and Destination must be different")
      end
    end

    def parent_child_match
      if self.order_line
        if (self.order_line.product != self.product) || (self.order_line.origin_location != self.origin_location) || (self.order_line.destination_location != self.destination_location)
          errors.add(:base, "Order Line and Shipment Line details do not match")
        end
      end
    end




end
