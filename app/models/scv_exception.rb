class ScvException < ActiveRecord::Base

  belongs_to :affected_object, polymorphic: true
  belongs_to :cause_object, polymorphic: true

  enum status: [ :open, :closed, :archived]
  
  validates :exception_type, :priority, :status, :affected_object_id, :affected_object_type, :cause_object_id, :cause_object_type, presence: true
  validate :valid_priority?
  validate :valid_type?

  def is_root_exception? 
    root_exception = true
    ScvException.where(cause_object: affected_object).count > 0 ? root_exception = false : nil
    return root_exception 
  end

  def child_exceptions
    @child_exceptions = ScvException.where(cause_object: affected_object)
  end

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
    scv_exception = where(affected_object: affected_object, cause_object: cause_object, exception_type: row["exception_type"]).first
    return scv_exception
  end

  def self.find_object_by(object_type, object_reference)
    matching_object = nil
    case object_type
      when "OrderLine"
        matching_object = OrderLine.where(order_line_number: object_reference).first
      when "ShipmentLine"
        matchin_object = ShipmentLine.where(shipment_line_number: object_reference).first
      when "Milestone"
        matching_object = Milestone.where(reference_number: object_reference).first
      when "WorkOrder"
        matching_object = WorkOrder.where(work_order_number: object_reference).first
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
        @object_reference_number = ip.reference_number
      when "WorkOrder"
        @object_reference_number = WorkOrder.find(attributes[object_id]).try(:work_order_number)
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
        self.affected_object_id = InventoryProjection.find_by_reference_number(ref_number).try(:id)
      when "WorkOrder"
        self.affected_object_id = WorkOrder.where(work_order_number: ref_number).first.try(:id)
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
        self.cause_object_id = InventoryProjection.find_by_reference_number(ref_number).try(:id)
      when "WorkOrder"
        self.cause_object_id = WorkOrder.where(work_order_number: ref_number).first.try(:id)
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

  def humanized_affected_object_date
    @humanize_affected_object_date = humanized_date_format("affected_object_date")
    @humanize_affected_object_date
  end
 
  def humanized_cause_object_date
    @humanized_cause_object_date = humanized_date_format("cause_object_date")
    @humanized_cause_object_date
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

    def humanized_date_format(attribute)
      formatted_date = nil
      formatted_date = self.attributes[attribute].to_formatted_s(:short) if self.attributes[attribute]
      return formatted_date
    end

end
