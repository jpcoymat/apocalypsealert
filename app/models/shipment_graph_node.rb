class ShipmentGraphNode

  attr_accessor :location
  attr_accessor :node_id
  attr_accessor :node_label

  def initialize(location)
    @location = location
    @node_id = location.id
    @node_label = location.code
  end

end
