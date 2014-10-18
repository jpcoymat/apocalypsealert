class ShipmentGraph

  attr_accessor :nodes
  attr_accessor :edges
  attr_accessor :graph_id

  def initialize(root_shipment)
    root_node = ShipmentGraphNode.new(root_shipment.origin_location)
    sister_node = ShipmentGraphNode.new(root_shipment.destination_location)
    @nodes = [root_node, sister_node]
    @edges = [ShipmentGraphEdge.new(root_shipment)]
    @graph_id = "graph" + root_shipment.id.to_s
    next_shipment = root_shipment.next_leg_shipment
    while next_shipment
      node = ShipmentGraphNode.new(next_shipment.destination_location)
      @nodes << node unless @nodes.include?(node)
      edge = ShipmentGraphEdge.new(next_shipment)
      @edges << edge unless @edges.include?(edge)
      next_shipment = next_shipment.next_leg_shipment
    end
  end


end
