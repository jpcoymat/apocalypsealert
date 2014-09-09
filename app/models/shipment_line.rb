class ShipmentLine < ActiveRecord::Base


  belongs_to :product
  belongs_to :order_line

  validates :shipment_line_number, :mode, :quantity, :customer_organization_id, :product_id, :eta, :etd, presence: true
  validates_uniqueness_of :shipment_line_number, scope: :customer_organization_id
  validate :origin_or_destination
  validate :parent_child_match
  validate :arrival_after_departure
  validate :different_locations

  has_many :milestones, as: :associated_object
 

  def self.modes
    @@modes = ["Ocean", "Truck", "Air", "Rail", "Intermodal", "Parcel"]
  end

  def origin_location
    @origin_location = Location.where(id: self.origin_location_id).first
  end

  def self.import(file_path)
    spreadsheet = open_spreadsheet(file_path)
    header = spreadsheet.row(1)
    (2..spreadsheet.last_row).each do |i|
      row = Hash[[header, spreadsheet.row(i)].transpose]
      shipment_line = where(shipment_line_number: row["shipment_line_number"]).first || new
      shipment_line.attributes = row
      shipment_line.save
    end
  end

  def self.open_spreadsheet(file_path)
    case File.extname(file_path)
      when ".csv"
        Roo::CSV.new(file_path)
      when ".xls"
        Roo::Excel.new(file_path)
      when ".xlsx"
        Roo::Excelx.new(file_path)
      else raise "Unknown file type: #{file.original_filename}"
    end
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

  def origin_location_name  
    origin_location.try(:name)
  end

  def origin_location_name=(location_name)
    self.origin_location_id = Location.where(name: location_name).first.try(:id)
  end

  def destination_location_name
    destination_location.try(:name)
  end

  def destination_location_name=(location_name)
    self.destination_location_id = Location.where(name: location_name).first.try(:id)
  end


  def order_line_number
    order_line.try(:order_line_number)
  end
  
  def order_line_number=(order_line_number)
    self.order_line_id = OrderLine.where(order_line_number: order_line_number).first.try(:id)
  end

  def product_name
    product.try(:name)
  end

  def product_name=(product_name)
    self.product_id = Product.where(name: product_name).first.try(:id)
  end

  def product_code
    self.product.try(:code)
  end

  def product_code=(product_code)
    self.product_id = Product.where(code: product_code).first.try(:id)
  end


  def carrier_organization
    @carrier_organization = self.carrier_organization_id ? Organization.find(self.carrier_organization_id) : nil
  end

  def carrier_organization=(organization)
    self.carrier_organization_id = organization.try(:id)
  end

  def carrier_organization_name
    carrier_organization.try(:name)
  end

  def carrier_organization_name=(carrier_name)
    self.carrier_organization_id = Organization.where(name: carrier_name).first.try(:id)
  end

  def forwarder_organization
    @forwarder_organization = self.forwarder_organization_id ? Organization.find(self.forwarder_organization_id) : nil
  end

  def forwarder_organization=(organization)
    self.forwarder_organization_id = organization.try(:id)
  end

  def forwarder_organization_name
    forwarder_organization.try(:name)
  end

  def forwarder_organization_name=(forwarder_name)
    self.forwarder_organization_id = Organization.where(name: forwarder_name).first.try(:id)
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

  def customer_organization_name=(customer_name)
    self.customer_organization_id = Organization.where(name: customer_name).first.try(:id)
  end

  def affected_scv_exceptions
    @affected_scv_exceptions = ScvException.where(affected_object_type: self.class.to_s, affected_object_id: self.id)
  end

  def cause_scv_exceptions
    @cause_scv_exceptions = ScvException.where(cause_object_type: self.class.to_s, cause_object_id: self.id)
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
