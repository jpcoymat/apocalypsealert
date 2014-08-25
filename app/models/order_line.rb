class OrderLine < ActiveRecord::Base

  belongs_to :product

  validates :order_line_number, :quantity, :customer_organization_id, :product_id, :eta, :etd, presence: true
  validates_uniqueness_of :order_line_number, scope: :customer_organization_id
  validate :origin_or_destination
  validate :different_customer_and_supplier
  validate :arrival_after_departure
  validate :different_locations

  has_many :shipment_lines

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

  def product_name=(product_name)
    self.product_id = Product.where(name: product_name).first.id
  end

  def supplier_organization
    @supplier_organization = Organization.find(self.supplier_organization_id)
  end

  def supplier_organization_name
    supplier_organization.try(:name)
  end

  def supplier_organization_name=(organization_name)
    self.supplier_organization_id = Organization.where(name: organization_name).first.id
  end

  def supplier_organization=(organization)
    self.supplier_organization_id = organization.try(:id)
  end 

  def customer_organization
    @customer_organization = Organization.find(self.customer_organization_id)
  end

  def customer_organization=(organization)
    self.customer_organization_id = organization.try(:id)
  end

  def customer_organization_name
    customer_organization.try(:name)
  end

  def customer_organization_name=(organization_name)
    self.customer_organization_id = Organization.where(name: organization_name).first.id
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

    def different_customer_and_supplier
      if customer_organization == supplier_organization
        errors.add(:base, "Supplier and Customer must be different orgs")
      end
    end

end
