class OrderLine < ActiveRecord::Base


  enum status: [ :open, :partially_shipped, :fully_shipped, :closed, :cancelled]

  belongs_to :product

  validates :order_line_number, :quantity, :customer_organization_id, :product_id, :eta, :etd, presence: true
  validates_uniqueness_of :order_line_number, scope: :customer_organization_id
  validate :origin_or_destination
  validate :arrival_after_departure
  validate :different_locations
  validate :different_customer_and_supplier
  validate :valid_order_type
 
  has_many :shipment_lines
  has_many :milestones, as: :associated_object

  def self.import(file_path)
    spreadsheet = open_spreadsheet(file_path)
    header = spreadsheet.row(1)
    (2..spreadsheet.last_row).each do |i|
      row = Hash[[header, spreadsheet.row(i)].transpose]
      order_line = where(order_line_number: row["order_line_number"]).first || new
      order_line.attributes = row
      order_line.is_active = true
      order_line.save
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

  def self.order_types
    @@order_types = ["Inbound", "Outbound"]
    @@order_types
  end

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

  def origin_location_name=(location_name)
    logger.debug "Setting origin location"
    self.origin_location_id = Location.where(name: location_name).first.try(:id)
  end

  def destination_location_name=(location_name)
    logger.debug "Setting dest location"
    self.destination_location_id = Location.where(name: location_name).first.try(:id)
  end
  
  def origin_location_name
    origin_location.try(:name)
  end

  def destination_location_name
    destination_location.try(:name)
  end


  def origin_location_code
    origin_location.try(:code)
  end


  def destination_location_code
    destination_location.try(:code)
  end

  def origin_location_code=(location_code)
    self.origin_location_id = Location.where(code: location_code).first.try(:id)
  end

  def destination_location_code=(location_code)
    self.destination_location_id = Location.where(code: location_code).first.try(:id)
  end

  def product_name
    self.product.try(:name)
  end

  def product_name=(product_name)
    logger.debug "setting product"
    self.product_id = Product.where(name: product_name).first.try(:id)
  end

  def product_code
    self.product.try(:code)
  end

  def product_code=(product_code)
    self.product_id = Product.where(code: product_code).first.try(:id)
  end


  def supplier_organization
    @supplier_organization = self.supplier_organization_id ? Organization.find(self.supplier_organization_id) : nil
  end

  def supplier_organization_name
    supplier_organization.try(:name)
  end

  def supplier_organization_name=(organization_name)
    logger.debug "Setting supplier org"
    self.supplier_organization_id = Organization.where(name: organization_name).first.try(:id)
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
    logger.debug "setting customer org"
    customer_organization.try(:name)
  end

  def customer_organization_name=(organization_name)
    self.customer_organization_id = Organization.where(name: organization_name).first.try(:id)
  end

  def affected_scv_exceptions
    @affected_scv_exceptions = ScvException.where(affected_object_type: self.class.to_s, affected_object_id: self.id)
  end

  def cause_scv_exceptions
    @cause_scv_exceptions = ScvException.where(cause_object_type: self.class.to_s, cause_object_id: self.id)
  end

  def shipped_quantity
    @shipped_quantity = 0
    shipment_lines.each {|sl| @shipped_quantity += sl.quantity}
    @shipped_quantity
  end

  def open_quantity
    self.quantity - shipped_quantity
  end

  def total_shipments
    shipment_lines.count
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
      if self.origin_location_id == self.destination_location_id
        errors.add(:base, "Origin and Destination must be different")
      end
    end

    def different_customer_and_supplier
      if self.customer_organization_id == self.supplier_organization_id
        errors.add(:base, "Supplier and Customer must be different orgs")
      end
    end

    def valid_order_type
      errors.add(:base, "Invalid Order Type") unless OrderLine.order_types.include?(self.order_type)
    end

end
