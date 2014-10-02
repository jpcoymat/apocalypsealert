class ExceptionGraphEdge

  attr_accessor :source_node
  attr_accessor :source
  attr_accessor :target_node
  attr_accessor :target
  attr_accessor :edge_id

  def edge_id
    @edge_id = @source_node.node_id + "-" + @target_node.node_id
    @edge_id
  end

  def initialize(source_node, target_node)
    @source_node = source_node
    @source = @source_node.node_id
    @target_node = target_node
    @target = @target_node.node_id
    edge_id
  end
  


end
