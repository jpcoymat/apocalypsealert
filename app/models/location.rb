class Location < ActiveRecord::Base

  belongs_to :organization
  belongs_to :location_group

  validates :name, :code, :city, :country, presence: true
  validates :code, uniqueness: {scope: :organization_id}

  def origin_shipment_lines(options = {})
    @origin_shipment_lines = shipment_lines("origin", options)
  end

  def origin_shipment_line_quantity(options = {})
    @origin_shipment_line_quantity = origin_shipment_lines(options).sum("quantity").to_i
    @origin_shipment_line_quantity 
  end

  def destination_shipment_lines(options = {})
    @destination_shipment_lines = shipment_lines("destination", options)
  end

  def destination_shipment_line_quantity(options = {})
   @destination_shipment_line_quantity = destination_shipment_lines(options).sum("quantity").to_i
   @destination_shipment_line_quantity
  end

  def origin_order_lines(options = {})
    @origin_order_lines = order_lines("origin", options)
  end

  def origin_order_line_quantity(options = {})
    @origin_order_line_quantity = origin_order_lines(options).sum("quantity").to_i
    @origin_order_line_quantity
  end

  def destination_order_lines(options = {})
    @destination_order_lines = order_lines("destination", options)
  end

  def destination_order_line_quantity(options = {})
    @destination_order_line_quantity = destination_order_lines(options).sum("quantity").to_i
    @destination_order_line_quantity
  end

  def inventory_projections(options = {})
    opts = options.clone
    @inventory_projections = InventoryProjection.where(location_id: self.id)
    @inventory_projections = @inventory_projections.where(product_id: opts[:product_id]) if opts[:product_id]
    @inventory_projections = @inventory_projections.where("product_id = (select id from products where name = '#{opts[:product_name]}'") if opts[:product_name]
    @inventory_projections = @inventory_projections.where("product_id in (select id from products where product_category_id = #{opts[:product_category_id]}") if opts[:product_category_id]
    @inventory_projections = @inventory_projections.where("product_id in (select id from products where product_category_id in (#{opts[:product_categories]}))") if opts[:product_categories]
    @inventory_projections
  end

  def inventory_projection_quantity(options = {})
    @inventory_projection_quantity = inventory_projections(options).sum("available_quantity")
    @inventory_projection_quantity
  end 

  def store_exceptions(options = {})
    ip_ids = inventory_projections(options).ids.to_s.chop![1..-1]
    ip_ids = "-1" if (ip_ids.nil? or ip_ids == "")
    @store_exceptions = ScvException.where("affected_object_type = 'InventoryProjection' and affected_object_id in (#{ip_ids})")
    @store_exceptions  
  end

  def work_orders(options = {})
    opts = options.clone
    @work_orders = WorkOrder.where(location_id: self.id)
    @work_orders = @work_orders.where(product_id: opts[:product_id]) if opts[:product_id]
    @work_orders = @work_orders.where("product_id = (select id from products where name =  '#{opts[:product_name]}'") if opts[:product_name]
    @work_orders = @work_orders.where("product_id in (select id from products where product_category_id = #{opts[:product_category_id]}") if opts[:product_category_id]
    @work_orders = @work_orders.where("product_id in (select id from products where product_category_id in (#{opts[:product_categories]}))") if opts[:product_categories]
    @work_orders
  end

  def work_order_quantity(options = {})
    @work_order_quantity = work_orders(options).sum("quantity")
    @work_order_quantity 
  end

  def make_exceptions(options = {})
    wo_ids = work_orders(options).ids.to_s.chop![1..-1]
    wo_ids = "-1" if (wo_ids.nil? or wo_ids == "")
    @work_order_exceptions = ScvException.where("affected_object_type = 'WorkOrder' and affected_object_id in (#{wo_ids})")
    @work_order_exceptions
  end

  def make_exception_quantity(options = {})
    @make_exception_quantity = make_exceptions(options).sum("abs(affected_object_quantity - cause_object_quantity)").to_i
    @make_exception_quantity
  end

  def move_exceptions(options = {})
    @move_exceptions = shipment_line_exceptions("destination", options)
    @move_exceptions
  end
 
  def source_exceptions(options = {})
    @source_exceptions = order_line_exceptions("destination", options)
    @source_exceptions
  end

  def deliver_exceptions(options = {})
    @deliver_exceptions = order_line_exceptions("origin", options)
    @deliver_exceptions
  end

  def shipment_inbound_quantity(options = {})
    @shipment_inbound_quantity = total_shipment_quantity("destination", options)
    @shipment_inbound_quantity
  end

  def shipment_outbound_quantity(options = {})
    @shipment_outbound_quantity = total_shipment_quantity("origin", options)
    @shipment_outbound_quantity
  end

  def order_ibound_quantity(options = {})
    @order_ibound_quantity = total_order_quantity("destination", options)
    @order_ibound_quantity    
  end

  def order_outbound_quantity(options = {})
    @order_outbound_quantity = total_order_quantity("origin", options)
    @order_outbound_quantity
  end

  def store_exception_quantity(options = {})
    @store_exception_quantity = store_exceptions(options).sum("abs(affected_object_quantity - cause_object_quantity)").to_i
    @store_exception_quantity
  end

  def move_exception_quantity(options = {})
    @move_exception_quantity = shipment_at_risk_quantity("destination", options)
    @move_exception_quantity
  end

  def source_exception_quantity(options = {})
    @source_exception_quantity = order_at_risk_quantity("destination", options) 
    @source_exception_quantity
  end

  def deliver_exception_quantity(options = {})
    @deliver_exception_quantity = order_at_risk_quantity("origin", options) 
    @deliver_exception_quantity
  end 

  def has_exception?
    if source_exceptions.count > 0 or make_exceptions.count > 0 or move_exceptions.count > 0 or store_exceptions.count > 0 or deliver_exceptions.count > 0
      return true
    else
      return false 
    end 
  end

  def deleteable?
    origin_shipment_lines.empty? and destination_shipment_lines.empty? and origin_order_lines.empty? and destination_order_lines.empty? and inventory_projections.empty?
  end

  def housed_products
    @housed_products = []
    order_lines("destination").each {|ol| @housed_products << ol.product unless @housed_products.include?(ol.product) }
    shipment_lines("destination").each {|sl| @housed_products << sl.product unless @housed_products.include?(sl.product)}
    order_lines("origin").each {|ol| @housed_products << ol.product unless @housed_products.include?(ol.product)}
    @housed_products  
  end

  def total_exception_quantity(options = {})
    @total_exception_quantity = 0
    all_exceptions(options).each {|excptn| @total_exception_quantity += excptn.quantity_at_risk.to_i}
    @total_exception_quantity
  end

  def all_exceptions(options = {})
    @all_exceptions = [source_exceptions(options).all]
    @all_exceptions << make_exceptions(options).all
    @all_exceptions << move_exceptions(options).all
    @all_exceptions << store_exceptions(options).all
    @all_exceptions << deliver_exceptions(options).all
    @all_exceptions.flatten!
    @all_exceptions   
  end   
 
  def source_percentage_risk(options = {})
    nominator = source_exception_quantity(options)
    if nominator > 0
      denominator = destination_order_line_quantity(options)
      return (nominator.to_f/denominator.to_f*100).round(2)
    else
      return  0
    end 
  end

  def make_percentage_risk(options = {})
    nominator = make_exception_quantity(options) 
    if nominator > 0 
      denominator = work_order_quantity(options)
      return (nominator.to_f/denominator.to_f*100).round(2)
    else
      return 0
    end
  end

  def move_percentage_risk(options = {})
    nominator = move_exception_quantity(options)
    if nominator > 0
      denominator = destination_shipment_line_quantity(options)
      return (nominator.to_f/denominator.to_f*100).round(2)
    else
      return 0
    end 
  end

  def store_percentage_risk(options = {})
    nominator = store_exception_quantity(options)
    if nominator > 0
      denominator = inventory_projection_quantity(options) 
      return (nominator.to_f/denominator.to_f*100).round(2)
    else
      return 0
    end
  end

  def deliver_percentage_risk(options = {})
    nominator = deliver_exception_quantity
    if nominator > 0
      denominator = origin_order_line_quantity(options)
      return (nominator.to_f/denominator.to_f*100).round(2)
    else
      return 0
    end
  end


  protected 

    def shipment_lines(direction, options = {})
      opts = options.clone
      attribute_name = direction + "_location_id"
      shipment_lines = ShipmentLine.where("#{attribute_name} = #{self.id}")
      if direction == "destination"
        shipment_lines = shipment_lines.where(shipment_type: "Inbound")
      elsif direction == "origin"
        shipment_lines = shipment_lines.where(shipment_type: "Outbound")
      end
      shipment_lines = shipment_lines.where(product_id: opts[:product_id]) if opts[:product_id]
      shipment_lines = shipment_lines.where("product_id = (select id from products where name = '#{opts[:product_name]}'") if opts[:product_name]
      shipment_lines = shipment_lines.where("product_id in (select id from products where product_category_id = #{opts[:product_category_id]})") if opts[:product_category_id]    
      shipment_lines = shipment_lines.where("product_id in (select id from products where product_category_id in (#{opts[:product_categories]})") if opts[:product_categories]
      return shipment_lines
    end

    def order_lines(direction, options = {})
      opts = options.clone
      attribute_name = direction + "_location_id"
      order_lines = OrderLine.where("#{attribute_name} = #{self.id}")
      if direction == "destination"
        order_lines = order_lines.where(order_type: "Inbound")
      elsif direction == "origin"
        order_lines = order_lines.where(order_type: "Outbound")
      end
      order_lines = order_lines.where(product_id: opts[:product_id]) if opts[:product_id]
      order_lines = order_lines.where("product_id = (select id from products where name = '#{opts[:product_name]}'") if opts[:product_name]
      order_lines = order_lines.where("product_id in (select id from products where product_category_id = #{opts[:product_category_id]})") if opts[:product_category_id]
      order_lines = order_lines.where("product_id in (select id from products where product_category_id in (#{opts[:product_categories]})") if opts[:product_categories]
      return order_lines
    end

    def shipment_line_exceptions(direction, options = {})
      ship_line_ids = shipment_lines(direction, options).ids.to_s.chop![1..-1]
      ship_line_ids = "-1" if (ship_line_ids.nil? or ship_line_ids == "")
      @shipment_line_exceptions = ScvException.where("affected_object_type = 'ShipmentLine' and affected_object_id in (#{ship_line_ids})")
      @shipment_line_exceptions
    end  

    def order_line_exceptions(direction, options = {})
      ol_ids = order_lines(direction, options).ids.to_s.chop![1..-1]
      ol_ids = "-1" if (ol_ids.nil? or ol_ids == "")
      @order_line_exceptions = ScvException.where("affected_object_type = 'OrderLine' and affected_object_id in (#{ol_ids})")
      @order_line_exceptions
    end  

    def total_shipment_quantity(direction, options = {})
      @total_shipment_quantity = shipment_lines(direction, options).sum("quantity").to_i
      @total_shipment_quantity
    end

    def total_order_quantity(direction, options = {})
      @total_order_quantity = order_lines(direction, options).sum("quantity").to_i
      @total_order_quantity
    end

    def shipment_at_risk_quantity(direction, options = {})
      @shipment_at_risk_quantity = shipment_line_exceptions(direction, options).sum("abs(affected_object_quantity - cause_object_quantity)")
      @shipment_at_risk_quantity
    end

    def order_at_risk_quantity(direction, options = {})
      @order_at_risk_quantity = order_line_exceptions(direction, options).sum("abs(affected_object_quantity - cause_object_quantity)")
      @order_at_risk_quantity
    end

end
