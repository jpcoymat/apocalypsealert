class InventoryProjection < ActiveRecord::Base

  belongs_to :location
  belongs_to :product

  validates :location_id, :product_id, :projected_for, :available_quantity, presence: true
  validates :product_id, uniqueness: {scope: [:projected_for, :location_id], message: "Projection for product/location/date exists"}

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


  def location_name
    location.try(:name)
  end

  def location_name=(location_name)
    self.location_id = Location.where(name: location_name).first.try(:id)
  end

  def location_code
    location.try(:code)
  end

  def location_code=(location_code)
    self.location_id = Location.where(code: location_code).first.try(:id)
  end

  def self.find_by_reference_number(reference_number)
    inventory_projection = nil
    references = reference_number.split("/")
    if references.count == 3
      product = Product.where(code: references[0]).first
      if product
        location = Location.where(code: references[1]).first
        if location  
          inventory_projection = where(product: product, location: location, projected_for: Date.parse(references[2])).first
        end
      end
    end
    inventory_projection
  end

  def self.import(file_path)
    spreadsheet = open_spreadsheet(file_path)
    header = spreadsheet.row(1)
    (2..spreadsheet.last_row).each do |i|
      row = Hash[[header, spreadsheet.row(i)].transpose]
      inventory_projection = find_import_match(row) || new
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

  def self.find_import_match(row)
    p = Product.where(name: row["product_name"])
    if p
      l = Location.where(name: row["location_name"])
      if l
        ip = InventoryProjection.where(product: p, location: l, projected_for: row["projected_for"]).first
        return ip
      else
        return nil
      end
    else
      return nil
    end
  end

  def self.inventory_positions(search_params)
    inventory_positions = []
    location_id = search_params["location_id"]
    product_category = search_params["product_category_id"]
    product_id = search_params["product_id"]
    if location_id 
      location = Location.find(location_id)
      if location 
        if product_category and product_id.nil?
          products = Product.where(product_category_id: product_category).all
          products.each do |prod|
            inv_pos = where(location: location, product: prod).first
            inventory_positions << inv_pos if inv_pos
          end
        elsif product_id and Product.find(product_id)
          inv_pos = where(location: location, product: Product.find(product_id)).first
          inventory_positions << inv_pos if inv_pos
        end  
      end
    end
    return inventory_positions
  end

  def self.position_projections(inventory_position)
    projections = where(product: inventory_position.product, location: inventory_position.location).order(projected_for: :asc)
    return projections
  end

  def reference_number
    product.code + "/" + location.code + "/" + self.projected_for.to_s
  end

  def reference_number=(reference_number)
    references = reference_number.split("/")
    if references.count == 3
      self.product_id = Product.where(code: references[0]).first.try(:id)
      self.location_id = Location.where(code: references[1]).first.try(:id)
      self.projected_for = Date.parse(references[2])
    end
  end

  def affected_scv_exceptions
    @affected_scv_exceptions = ScvException.where(affected_object_type: self.class.to_s, affected_object_id: self.id)
  end

  def cause_scv_exceptions
    @cause_scv_exceptions = ScvException.where(cause_object_type: self.class.to_s, cause_object_id: self.id)
  end

end
