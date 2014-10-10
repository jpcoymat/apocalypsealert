class ExceptionGraph
  
  attr_accessor :root_exception
  attr_accessor :root_node
  attr_accessor :nodes
  attr_accessor :edges

  def initialize(root_exception)
    @root_exception = root_exception
    @root_node = ExceptionGraphNode.new(@root_exception.cause_object)
    sister_node = ExceptionGraphNode.new(@root_exception.affected_object)
    @nodes = [@root_node, sister_node]
    @edges = [ExceptionGraphEdge.new(@root_node, sister_node)]
    add_nodes
  end

  def add_nodes(start_exception = @root_exception)
    start_exception.child_exceptions.each do |child|
      source_node = ExceptionGraphNode.new(child.cause_object)
      @nodes << source_node unless node_exists?(source_node)
      target_node = ExceptionGraphNode.new(child.affected_object)
      @nodes << target_node unless node_exists?(target_node)  
      edge = ExceptionGraphEdge.new(source_node, target_node)
      @edges << edge unless @edges.include?(edge)
      root_edge = ExceptionGraphEdge.new(@root_node, target_node)
      @edges << root_edge unless @edges.include?(root_edge) 
      add_nodes(child)
    end
  end

  def node_exists?(node)
    node_exists = false
    @nodes.each do |node_element| 
      if node_element.node_object == node.node_object
        node_exists = true
        break
      end 
    end
    return node_exists
  end

  def convert_to_json
    json = '{ "nodes": ['
    @nodes.each do |node| 
      json += '{"id": "' + node.node_id + '", "label": "' + node.node_label + '"}'
      unless node == @nodes.last
        json += ','  
      end
    end
    json += '], "edges" : ['
    @edges.each do |edge|
      json += '{"id": "' + edge.edge_id + '", "source": "' + edge.source + '", "target": "' + edge.target + '"}'
      unless edge == @edges.last
        json += ','
      end  
    end
     json += ']}'
     return json
  end

end
