class Milestone < ActiveRecord::Base

  validates :reference_number, :associated_object_type, :associated_object_id, presence: true
  validate :valid_reason_code
  validate :valid_milestone_type

  belongs_to :associated_object, polymorphic: true

  def self.import(file_path)
    spreadsheet = open_spreadsheet(file_path)
    header = spreadsheet.row(1)
    (2..spreadsheet.last_row).each do |i|
      row = Hash[[header, spreadsheet.row(i)].transpose]
      milestone = where(reference_number: row["reference_number"]).first || new
      milestone.attributes = row
      milestone.save
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

  def self.reason_codes
    @@reason_codes = ["Negligence", "No Double Check", "Missed", "SOP Not Followed", "Typo Error"]
  end 

  def self.milestone_types
    @@milestone_types = ["Original Order",
		"PO Declined",
		"PO Accepted",	
		"Booked w/Srvc Prvdr",
		"Bkd w/Carrier",
		"Rcvd Fwdr",
		"Loaded at Pickup", 
		"Est. Departure from POL",
		"Est. Arrival at POD",
		"Departed",
		"Shipped (ASN)",
		"Arrived",
		"Scheduled Pickup (Dest.)",
		"Scheduled Delivery (Dest.)",
		"Enroute to Dlvry Loc",
		"Delivered"]
  end

  def associated_object_reference
     case self.associated_object_type
      when "OrderLine"
        @associated_object_reference = OrderLine.find(self.associated_object_id).order_line_number
       when "ShipmentLine"
        @associated_object_reference = ShipmentLine.find(self.associated_object_id).shipment_line_number
      when "WorkOrder"
        @associated_object_reference = WorkOrder.find(self.associated_object_id).work_order_number
      when "InventoryProjection"
        @associated_object_reference = InventoryProjection.find(self.associated_object_id).reference_number
      else
        @associated_object_reference = nil
    end
  end

  def associated_object_reference=(reference_number)
    case self.associated_object_type
      when "OrderLine"
        self.associated_object_id = OrderLine.where(order_line_number: reference_number).first.try(:id)
      when "ShipmentLine"
        self.associated_object_id = ShipmentLine.where(shipment_line_number: reference_number).first.try(:id)
      when "WorkOrder"
        self.associated_object_id = WorkOrder.where(work_order_number: reference_number).first.try(:id)
      when "InventoryProjection"
        self.associated_object_id = InventoryProjection.find_by_reference_number(reference_number)
    end
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
    self.customer_organization_id = Organization.where(name: organization_name).first.try(:id)
  end
 
  def create_organization
    @create_organization = Organization.find(self.create_organization_id)
  end

  def create_organization=(organization)
    self.create_organization_id = organization.try(:id)
  end

  def create_organization_name
    create_organization.try(:name)
  end

  def create_organization_name=(organization_name)
    self.create_organization_id = Organization.where(name: organization_name).first.try(:id)
  end

  def create_user
    @create_user = User.find(self.create_user_id)
  end

  def create_user=(user)
    self.create_user_id = user.try(:id)
  end


  def affected_scv_exceptions
    @affected_scv_exceptions = ScvException.where(affected_object_type: self.class.to_s, affected_object_id: self.id)
  end

  def cause_scv_exceptions
    @cause_scv_exceptions = ScvException.where(cause_object_type: self.class.to_s, cause_object_id: self.id)
  end


 
  protected
   
    def valid_reason_code
      unless Milestone.reason_codes.include?(self.reason_code) or self.reason_code.nil?
        errors.add(:base, "Invalid Reason Code")
      end
    end

    def valid_milestone_type
      unless Milestone.milestone_types.include?(self.milestone_type) or self.milestone_type.nil?
        errors.add(:base, "Invalid Milestone Type")
      end
    end

end
