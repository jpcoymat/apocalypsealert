class ExceptionGraphNode

  attr_accessor :node_object
  attr_accessor :node_id
  attr_accessor :node_label
  attr_accessor :x_position
  attr_accessor :y_position

  def initialize(node_object, x_position, y_position)
    @node_object = node_object
    @x_position = x_position
    @y_position = y_position
    node_id
    node_label
  end

  def node_id
    @node_id = @node_object.class.to_s + @node_object.id.to_s
    @node_id
  end

  def node_label
    @node_label = @node_object.class.to_s + " "
    case @node_object.class.to_s
      when "Milestone"
        @node_label += @node_object.reference_number
      when "ShipmentLine"
        @node_label += @node_object.shipment_line_number
      when "OrderLine"
        @node_label += @node_object.order_line_number
      when "WorkOrder"
        @node_label += @node_object.work_order_number
      when "InventoryProjection"
        @node_label += @node_object.reference_number
    end
    @node_label
  end

  

end
