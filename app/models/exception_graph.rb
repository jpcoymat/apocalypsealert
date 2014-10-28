class ExceptionGraph
  
  attr_accessor :root_exception
  attr_accessor :root_node
  attr_accessor :nodes
  attr_accessor :edges
  attr_accessor :depth

  def initialize(root_exception)
    @root_exception = root_exception
    @root_node = ExceptionGraphNode.new(@root_exception.cause_object, "#f00")
    sister_node = ExceptionGraphNode.new(@root_exception.affected_object)
    @nodes = [@root_node, sister_node]
    @edges = [ExceptionGraphEdge.new(@root_node, sister_node)]
    @depth = 2
    add_nodes
  end

  def add_nodes(start_exception = @root_exception)
    if start_exception.child_exceptions.count > 0 
      @depth += 1
      start_exception.child_exceptions.each do |child|
        source_node = ExceptionGraphNode.new(child.cause_object)
        @nodes << source_node unless node_exists?(source_node)
        target_node = ExceptionGraphNode.new(child.affected_object)
        @nodes << target_node unless node_exists?(target_node)  
        edge = ExceptionGraphEdge.new(source_node, target_node)
        @edges << edge unless @edges.include?(edge) unless edge_exists?(edge)
        add_nodes(child)
      end
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

  def edge_exists?(edge)
    duplicates = @edges.select {|ed| ed.edge_id == edge.edge_id}
    duplicates.count > 0 
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
