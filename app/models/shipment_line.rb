class ShipmentLine < ActiveRecord::Base


  enum status: [ :planned, :in_transit, :delivered, :cancelled]

  belongs_to :product
  has_one :order_itinerary
  has_one :order_line, through: :order_itinerary

  validates :shipment_line_number, :mode, :quantity, :customer_organization_id, :product_id, :eta, :etd, :origin_location_id, :destination_location_id, presence: true
  validates_uniqueness_of :shipment_line_number, scope: :customer_organization_id
  
  validate :arrival_after_departure
  validate :different_locations
  validate :valid_shipment_type

  has_many :milestones, as: :associated_object
 
  def next_leg_shipment
    @next_leg_shipment = nil
    next_itinerary = order_itinerary.next_order_itinerary
    @next_leg_shipment = next_itinerary.shipment_line if next_itinerary
    @next_leg_shipment
  end


  def self.modes
    @@modes = ["Ocean", "Truck", "Air", "Rail", "Intermodal", "Parcel"]
  end

  def self.shipment_types
    @@shipment_types = ["Inbound", "Outbound"]
  end


  def origin_location
    @origin_location = Location.where(id: self.origin_location_id).first
  end

  def self.import(file_path)
    spreadsheet = open_spreadsheet(file_path)
    header = spreadsheet.row(1)
    (2..spreadsheet.last_row).each do |i|
      row = Hash[[header, spreadsheet.row(i)].transpose]
      order_line = OrderLine.where(order_line_number: row["order_line_number"]).first
      row.delete("order_line_number")
      shipment_line = where(shipment_line_number: row["shipment_line_number"]).first || new
      shipment_line.attributes = row
      shipment_line.is_active = true
      if shipment_line.save and order_line
        order_itinerary = OrderItinerary.new(shipment_line: shipment_line, order_line: order_line)
        order_itinerary.set_leg_number
        order_itinerary.save
        order_itinerary.set_previous_order_itinerary
      end
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

    def valid_shipment_type
      errors.add(:base, "Shipment Type not valid") unless ShipmentLine.shipment_types.include?(self.shipment_type)
    end


end
