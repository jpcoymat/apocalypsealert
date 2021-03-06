class ShipmentGraphEdge

  attr_accessor :source_node
  attr_accessor :source
  attr_accessor :target_node
  attr_accessor :target
  attr_accessor :edge_id
  attr_accessor :color
  attr_accessor :shipment


  def initialize(shipment)
    @shipment = shipment
    @source_node = shipment.origin_location
    @source = @source_node.try(:id)
    @target_node = shipment.destination_location
    @target = @target_node.try(:id)
    @color = ShipmentGraphEdge.status_colors[shipment.status]
    @edge_id = shipment.id    
  end

  def self.status_colors
    @@status_colors = {"delivered" => "#1dd754", "in_transit" => "#d7b81d", "planned" => "#2e2b20", "cancelled" => "#e21025"}
    @@status_colors
  end

  def self.bootstrap_class
    @@bootstrap_class = {"delivered" => "success", "in_transit" => "warning", "planned" => "info", "cancelled" => "danger"}
  end

end
