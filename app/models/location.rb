class Location < ActiveRecord::Base

  belongs_to :organization
  belongs_to :location_group

  validates :name, :code, :city, :country, presence: true
  validates :code, uniqueness: {scope: :organization_id}

  def origin_shipment_lines(options = {})
    @origin_shipment_lines = shipment_lines("origin", options)
  end

  def origin_shipment_line_quantity(options = {})
    @origin_shipment_line_quantity = 0
    origin_shipment_lines(options).each {|sl| @origin_shipment_line_quantity += sl.quantity}
    @origin_shipment_line_quantity 
  end

  def destination_shipment_lines(options = {})
    @destination_shipment_lines = shipment_lines("destination", options)
  end

  def destination_shipment_line_quantity(options = {})
   @destination_shipment_line_quantity = 0
   destination_shipment_lines(options).each {|sl| @destination_shipment_line_quantity += sl.quantity}
   @destination_shipment_line_quantity
  end

  def origin_order_lines(options = {})
    @origin_order_lines = order_lines("origin", options)
  end

  def origin_order_line_quantity(options = {})
    @origin_order_line_quantity = 0
    origin_order_lines(options).each {|ol| @origin_order_line_quantity += ol.quantity}
    @origin_order_line_quantity
  end

  def destination_order_lines(options = {})
    @destination_order_lines = order_lines("destination", options)
  end

  def destination_order_line_quantity(options = {})
    @destination_order_line_quantity = 0
    destination_order_lines(options).each {|ol| @destination_order_line_quantity += ol.quantity}
    @destination_order_line_quantity
  end

  def inventory_projections(options = {})
    opts = options.clone
    @inventory_projections = InventoryProjection.where(location_id: self.id)
    @inventory_projections = @inventory_projections.where(product_id: opts[:product_id]) if opts[:product_id]
    @inventory_projections = @inventory_projections.where("product_id = (select id from products where name = '#{opts[:product_name]}'") if opts[:product_name]
    @inventory_projections = @inventory_projections.where("product_id in (select id from products where product_category_id = #{opts[:product_category_id]}") if opts[:product_category_id]
    if opts[:product_categories]
      list_of_prod_cats = ""
      opts[:product_categories].each {|pc| list_of_prod_cats += pc + ","}
      list_of_prod_cats.chop!
      @inventory_projections = @inventory_projections.where("product_id in (select id from products where product_category_id in (#{list_of_prod_cats}))")
    end
    @inventory_projections
  end

  def inventory_projection_quantity(options = {})
    @inventory_projection_quantity = 0
    inventory_projections(options).each {|ip| @inventory_projection_quantity += ip.available_quantity}
    @inventory_projection_quantity
  end 

  def store_exceptions(options = {})
    @store_exceptions = []
    inventory_projections(options).each {|ip| @store_exceptions << ip.affected_scv_exceptions}
    @store_exceptions.flatten!
    @store_exceptions  
  end

  def work_orders(options = {})
    opts = options.clone
    @work_orders = WorkOrder.where(location_id: self.id)
    @work_orders = @work_orders.where(product_id: opts[:product_id]) if opts[:product_id]
    @work_orders = @work_orders.where("product_id = (select id from products where name =  '#{opts[:product_name]}'") if opts[:product_name]
    @work_orders = @work_orders.where("product_id in (select id from products where product_category_id = #{opts[:product_category_id]}") if opts[:product_category_id]
    if opts[:product_categories]
      list_of_prod_cats = ""
      opts[:product_categories].each {|pc| list_of_prod_cats += pc + ","}
      list_of_prod_cats.chop!
      @work_orders = @work_orders.where("product_id in (select id from products where product_category_id in (#{list_of_prod_cats}))")
    end
    @work_orders
  end

  def work_order_quantity(options = {})
    @work_order_quantity = 0
    work_orders(options).each {|wo| @work_order_quantity  += wo.quantity}
    @work_order_quantity 
  end

  def make_exceptions(options = {})
    @work_order_exceptions = []
    work_orders(options).each {|wo| @work_order_exceptions << wo.affected_scv_exceptions}
    @work_order_exceptions.flatten!
    @work_order_exceptions
  end

  def make_exception_quantity(options = {})
    @make_exception_quantity = 0
    make_exceptions(options).each {|se| @make_exception_quantity += se.quantity_at_risk}
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
    @store_exception_quantity = 0
    store_exceptions(options).each {|se| @store_exception_quantity += se.quantity_at_risk}
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
    total_excptn_qty = 0
    all_exceptions(options).each {|excptn| total_excptn_qty += excptn.quantity_at_risk}
    return total_excptn_qty
  end

  def all_exceptions(options = {})
    allexceptions = source_exceptions(options)
    allexceptions << make_exceptions(options)
    allexceptions << move_exceptions(options)
    allexceptions << store_exceptions(options)
    allexceptions << deliver_exceptions(options)
    allexceptions.flatten!
    return allexceptions   
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
      if opts[:product_categories]
        list_of_categories = ""
        opts[:product_categories].each {|pc| list_of_categories += pc + ","}
        list_of_categories.chop!
        shipment_lines = shipment_lines.where("product_id in (select id from products where product_category_id in (#{list_of_categories})")
      end
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
      if opts[:product_categories]
        list_of_categories = ""
        opts[:product_categories].each {|pc| list_of_categories += pc + ","}
        list_of_categories.chop!
        order_lines = order_lines.where("product_id in (select id from products where product_category_id in (#{list_of_categories})")
      end
      return order_lines
    end

    def shipment_line_exceptions(direction, options = {})
      shipment_exceptions = []
      shipment_lines(direction, options).each {|shipment_line| shipment_exceptions << shipment_line.affected_scv_exceptions }
      shipment_exceptions.flatten!
      return shipment_exceptions
    end  

    def order_line_exceptions(direction, options = {})
      order_line_exceptions = []
      order_lines(direction, options).each {|order_line| order_line_exceptions << order_line.affected_scv_exceptions}
      order_line_exceptions.flatten!
      return order_line_exceptions
    end  

    def total_shipment_quantity(direction, options = {})
      total_shipment_quantity = 0
      shipment_lines(direction, options).each {|sl| total_shipment_quantity += sl.quantity}
      return total_shipment_quantity
    end

    def total_order_quantity(direction, options = {})
      total_order_quantity = 0
      order_lines(direction, options).each {|ol| total_order_quantity += ol.quantity}
      return total_order_quantity
    end

    def shipment_at_risk_quantity(direction, options = {})
      shipment_at_risk_qty = 0
      shipment_line_exceptions(direction, options).each {|se| shipment_at_risk_qty += se.quantity_at_risk}
      return shipment_at_risk_qty
    end

    def order_at_risk_quantity(direction, options = {})
      order_at_risk_qty = 0
      order_line_exceptions(direction, options).each {|se| order_at_risk_qty += se.quantity_at_risk}
      return order_at_risk_qty
    end

end
