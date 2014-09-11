class WorkOrder < ActiveRecord::Base

  belongs_to :product
  belongs_to :location
  belongs_to :organization

  validates :work_order_number, :product_id, :location_id, :production_begin_date, :production_end_date, :quantity, :organization_id, presence: true
  validates :work_order_number, uniqueness: {scope: :organization_id}

  has_many :milestones, as: :associated_object

  def self.import(file_path)
    spreadsheet = open_spreadsheet(file_path)
    header = spreadsheet.row(1)
    (2..spreadsheet.last_row).each do |i|
      row = Hash[[header, spreadsheet.row(i)].transpose]
      work_order = where(work_order_number: row["work_order_number"]).first || new
      work_order.attributes = row
      work_order.is_active = true
      work_order.save
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


  def location_name=(location_name)
    self.location_id = Location.where(name: location_name).first.try(:id)
  end

  def location_name
    location.try(:name)
  end

  def location_code=(location_code)
    self.location_id = Location.where(code: location_code).first.try(:id)
  end

  def location_code
    location.try(:code)
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

  def organization_name
    organization.try(:name)
  end

  def organization_name=(organization_name)
    self.organization_id = Organization.where(name: organization_name).first.try(:id)
  end


end
