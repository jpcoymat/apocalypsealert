class OrderLine < ActiveRecord::Base

  belongs_to :product

  validates :order_line_number, :quantity, :customer_organization_id, :product_id, :eta, :etd, presence: true
  validates_uniqueness_of :order_line_number, scope: :customer_organization_id
  validate :origin_or_destination
  validate :arrival_after_departure
  validate :different_locations
  validate :different_customer_and_supplier
  
  has_many :shipment_lines

  def self.import(file_path)
    logger.debug "Calling open_spreadsheet"
    spreadsheet = open_spreadsheet(file_path)
    logger.debug "Getting header"
    header = spreadsheet.row(1)
    logger.debug "Starting to loop"
    (2..spreadsheet.last_row).each do |i|
      logger.debug "Now in row " + i.to_s
      row = Hash[[header, spreadsheet.row(i)].transpose]
      logger.debug "resulting hash: " + row.to_s
      order_line = where(order_line_number: row["order_line_number"]).first || new
      logger.debug "resulting order line: " + order_line.to_s
      logger.debug "now setting attributes"
      order_line.attributes = row
      order_line.save
    end
  end

  def self.open_spreadsheet(file_path)
    logger.debug "Open spreadsheet started"
    case File.extname(file_path)
      when ".csv" 
        logger.debug "CSV file input"
        Roo::CSV.new(file_path)
      when ".xls" 
        logger.debug "XLS file input"
        Roo::Excel.new(file_path)
      when ".xlsx" 
        logger.debug "XLST file input"
        Roo::Excelx.new(file_path)
      else raise "Unknown file type: #{file.original_filename}"
    end
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


  def product_name
    self.product.try(:name)
  end

  def product_name=(product_name)
    logger.debug "setting product"
    self.product_id = Product.where(name: product_name).first.try(:id)
  end

  def supplier_organization
    @supplier_organization = Organization.find(self.supplier_organization_id)
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

end
