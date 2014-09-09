class ScvException < ActiveRecord::Base

  belongs_to :affected_object, polymorphic: true
  belongs_to :cause_object, polymorphic: true

  enum status: [ :open, :closed, :archived]
  
  validates :exception_type, :priority, :status, :affected_object_id, :affected_object_type, :cause_object_id, :cause_object_type, presence: true
  validate :valid_priority?
  validate :valid_type?

  def self.priorities
    @@priorities = [1,2,3]
  end

  def self.exception_types
    @@exception_types = ["Quantity", "Date"]
  end

  def self.import(file_path)
    spreadsheet = open_spreadsheet(file_path)
    header = spreadsheet.row(1)
    (2..spreadsheet.last_row).each do |i|
      row = Hash[[header, spreadsheet.row(i)].transpose]
      scv_exception = find_import_match(row) || new
      scv_exception.attributes = row
      scv_exception.save
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
    affected_object = find_object_by(row["affected_object_type"], row["affected_object_reference_number"])
    cause_object = find_object_by(row["cause_object_type"], row["cause_object_reference_number"])
    scv_exception = where(affected_object: affected_object, cause_object: cause_object).first
  end

  def self.find_object_by(object_type, object_reference)
    matching_object = nil
    case object_type
      when "OrderLine"
        matching_object = OrderLine.where(order_line_number: object_reference)
      when "ShipmentLine"
        matchin_object = ShipmentLine.where(shipment_line_number: object_reference)
      when "Milestone"
        matching_object = Milestone.where(reference_number: object_reference)
      else
        nil
    end
    return matching_object
  end

  def object_reference_number(affected_or_cause)
    object_type = affected_or_cause + "_object_type"
    object_id = affected_or_cause + "_object_id"
    case attributes[object_type]  
      when "OrderLine"
        @object_reference_number = OrderLine.find(attributes[object_id]).try(:order_line_number)
      when "ShipmentLine"
        @object_reference_number = ShipmentLine.find(attributes[object_id]).try(:shipment_line_number) 
      when "Milestone"
        @object_reference_number = Milestone.find(attributes[object_id]).try(:reference_number)
      when "InventoryProjection" 
        ip = InventoryProjection.find(attributes[object_id])
        @object_reference_number = ip.product.try(:code) + "-" + ip.location.try(:code) + "-" + ip.projected_for.to_s
    end
    @object_reference_number
  end

  def affected_object_reference_number
    object_reference_number("affected")
  end

  def cause_object_reference_number
    object_reference_number("cause")
  end

  def affected_object_reference_number=(ref_number)
    case self.affected_object_type
      when "OrderLine"
        self.affected_object_id = OrderLine.where(order_line_number: ref_number).first.try(:id)
      when "ShipmentLine"
        self.affected_object_id =ShipmentLine.where(shipment_line_number: ref_number).first.try(:id)
      when "Milestone"
        self.affected_object_id = Milestone.where(reference_number: ref_number).first.try(:id)
      when "InventoryProjection"
        self.affected_object_id = InventoryPosition.find_by_reference_number(ref_number)
      end        
  end

  def cause_object_reference_number=(ref_number)
     case self.cause_object_type
      when "OrderLine"
        self.cause_object_id = OrderLine.where(order_line_number: ref_number).first.try(:id)
      when "ShipmentLine"
        self.cause_object_id =ShipmentLine.where(shipment_line_number: ref_number).first.try(:id)
      when "Milestone"
        self.cause_object_id = Milestone.where(reference_number: ref_number).first.try(:id)
      when "InventoryProjection"
        self.cause_object_id = InventoryProjection.find_by_reference_number(ref_number)
      end
  end

  def full_reference_number(affected_or_cause)
    object_type = affected_or_cause + "_object_type"
    self.attributes[object_type].titleize + " " + object_reference_number(affected_or_cause)
  end
  
  def affected_object_full_reference
    full_reference_number("affected")   
  end
  
  def cause_object_full_reference
    full_reference_number("cause")   
  end

  def quantity_at_risk
    @quantity_at_risk = (self.affected_object_quantity - self.cause_object_quantity).abs
    @quantity_at_risk
  end


  protected

    def valid_priority?
      unless ScvException.priorities.include?(self.priority)
        errors.add(:base, "Invalid Priority")
      end 
    end 
    
    def valid_type?
      unless ScvException.exception_types.include?(self.exception_type)
        errors.add(:base, "Invalid Exception Type")
      end
    end

end
