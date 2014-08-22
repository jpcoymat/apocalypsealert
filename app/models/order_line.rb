class OrderLine < ActiveRecord::Base

  belongs_to :organization
  belongs_to :product

  validates :order_line_number, :quantity, :organization_id, :product_id, :eta, :etd, presence: true
  validates_uniqueness_of :order_line_number, scope: :organization_id
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

  def product_name
    self.product.try(:name)
  end

  def product_name=(name)
    self.product_id = Product.where(name: name).first.id
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



end
