class OrderLineBreakdownJob

  @queue = :order_line_breakdown


  def self.perform(order_line_id)
    @order_line = OrderLine.find(order_line_id)
    OrderLine.major_attributes.each do |order_line_attribute|
      
    end
  end

  

  
  

end
