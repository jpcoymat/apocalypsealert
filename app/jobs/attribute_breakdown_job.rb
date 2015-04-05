class AttributeBreakdownJob

  @queue = :attribute_breakdown
  
  def self.perform(json_string)
    object_hash = JSON.load(json_string)
    case object_hash[:object_class]
      when "OrderLine"
        process_order_line(object_hash[:object_id])
      when "ShipLine"
    end
   
  end

  def self.process_order_line(order_line_id)
    order_line = OrderLine.find(order_line_id)
    OrderLine.major_attributes.each do |mjr_attr|
      at = AttributeTracker.new(order_line.class.to_s, mjr_attr.to_s, order_line.try(mjr_attr))
      at.add_record(order_line)
    end
  end


end
