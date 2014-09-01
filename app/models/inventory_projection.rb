class InventoryProjection < ActiveRecord::Base

  belongs_to :location
  belongs_to :product

  validates :location_id, :product_id, :projected_for, :available_quantity, presence: true

  def product_name
    product.try(:name)
  end

  def product_name=(product_name)
    self.product_id = Product.where(name: product_name).try(:id)
  end

  def location_name
    location.try(:name)
  end

  def location_name=(location_name)
    self.location_id = Location.where(name: location_name).try(:id)
  end

  def self.import(file_path)
    spreadsheet = open_spreadsheet(file_path)
    header = spreadsheet.row(1)
    (2..spreadsheet.last_row).each do |i|
      row = Hash[[header, spreadsheet.row(i)].transpose]
      inventory_projection = where(: row["order_line_number"]).first || new
      inventory_projection.attributes = row
      inventory_projection.save
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

end
