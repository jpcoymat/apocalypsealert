class Location < ActiveRecord::Base

  belongs_to :organization
  belongs_to :location_group

  has_many :work_orders
  has_many :inventory_projections

  validates :name, :code, :city, :country, presence: true
  validates :code, uniqueness: {scope: :organization_id}

  def origin_shipment_lines
    @origin_shipment_lines = shipment_lines("origin")
  end

  def destination_shipment_lines
    @destination_shipment_lines = shipment_lines("destination")
  end

  def origin_order_lines
    @origin_order_lines = order_lines("origin")
  end

  def destination_order_lines
    @destination_order_lines = order_lines("destination")
  end

  def inventory_positions(options = {})
    opts = options.clone
    @inventory_positions = []
    projections = inventory_projections
    projections = projections.where(product_id: opts[:product_id]) if opts[:product_id]
    projections = projections.where("product_id = (select id from products where name = '#{opts[:product_name]}'") if opts[:product_name]
    projections = projections.where("product_id in (select id from products where product_category_id = #{opts[:product_category_id]}") if opts[:product_category_id]
    projections.each do |projection| 
      inventory_position = InventoryProjection.inventory_position(projection.location, projection.product)
      @inventory_positions << inventory_position unless (@inventory_positions.include?(inventory_position) or inventory_position.nil?)
    end
    @inventory_positions
  end

  def inventory_quantity(options = {})
    @inventory_quantity = 0
    inventory_positions(options).each {|ip| @inventory_quantity += ip.available_quantity}
    @inventory_quantity
  end

  def inventory_exceptions(options = {})
    opts = options.clone
    @inventory_exceptions = []
    projections = inventory_projections
    projections = projections.where(product_id: opts[:product_id]) if opts[:product_id]
    projections = projections.where("product_id = (select id from products where name = '#{opts[:product_name]}'") if opts[:product_name]
    projections = projections.where("product_id in (select id from products where product_category_id = #{opts[:product_category_id]}") if opts[:product_category_id]
    projections.each {|ip| @inventory_exceptions << ip.affected_scv_exceptions}
    @inventory_exceptions.flatten!
    @inventory_exceptions  
  end

  def inventory_exception_quantity(options = {})
    inv_excptn_quantity = 0
    inventory_exceptions(options).each {|ie| inv_excptn_quantity += ie.quantity_at_risk}
    return inv_excptn_quantity
  end

  def work_order_exceptions(options = {})
    opts = options.clone
    @work_order_exceptions = []
    wos = work_orders
    wos = wos.where(product_id: opts[:product_id]) if opts[:product_id]
    wos = wos.where("product_id = (select id from products where name = '#{opts[:product_name]}'") if opts[:product_name]
    wos = wos.where("product_id in (select id from products where product_category_id = #{opts[:product_category_id]}") if opts[:product_category_id]
    wos.each {|wo| @work_order_exceptions << wo.affected_scv_exceptions}
    @work_order_exceptions.flatten!
    @work_order_exceptions
  end

  def inbound_shipment_line_exceptions(options = {})
    @inbound_shipment_line_exceptions = shipment_line_exceptions("destination", options)
    @inbound_shipment_line_exceptions
  end
 
  def inbound_order_line_exceptions(options = {})
    @inbound_order_line_exceptions = order_line_exceptions("destination", options)
    @inbound_order_line_exceptions
  end

  def outbound_order_line_exceptions(options = {})
    @outbound_order_line_exceptions = order_line_exceptions("origin", options)
    @outbound_order_line_exceptions
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

  def total_inbound_quantity(options = {})
    @total_inbound_quantity = shipment_inbound_quantity(options) + order_ibound_quantity(options)
    @total_inbound_quantity
  end 

  def total_outbound_quantity(options = {})
    @total_outbound_quantity = shipment_outbound_quantity(options) + order_outbound_quantity(options)
    @total_outbound_quantity
  end

  def inbound_exceptions(options = {})
    @inbound_exceptions = inbound_shipment_line_exceptions(options)
    @inbound_exceptions << inbound_order_line_exceptions(options)
    @inbound_exceptions.flatten!
    @inbound_exceptions
  end

  def inbound_shipment_at_risk_quantity(options = {})
    @inbound_shipment_at_risk_quantity = shipment_at_risk_quantity("destination", options)
    @inbound_shipment_at_risk_quantity
  end

  def inbound_order_at_risk_quantity(options = {})
    @inbound_order_at_risk_quantity = order_at_risk_quantity("destination", options) 
    @inbound_order_at_risk_quantity
  end

  def outbound_order_at_risk_quantity(options = {})
    @outbound_order_at_risk_quantity = order_at_risk_quantity("origin", options) 
    @outbound_order_at_risk_quantity
  end

  def total_inbound_quantity_at_risk(options = {})
    @total_inbound_quantity_at_risk = inbound_shipment_at_risk_quantity(options) + inbound_order_at_risk_quantity(options)
    @total_inbound_quantity_at_risk
  end

  def percentage_inbound_quantity_at_risk(options = {})
    @percentage_inbound_quantity_at_risk = 0.0 
    denominator = total_inbound_quantity(options).to_f
    if denominator > 0.0
      @percentage_inbound_quantity_at_risk = ((total_inbound_quantity_at_risk(options).to_f/denominator)*100).round(2)
    end
    @percentage_inbound_quantity_at_risk
  end 

  def percentage_outbound_quantity_at_risk(options = {})
    @percentage_outbound_quantity_at_risk = 0.0
    denominator = total_outbound_quantity(options).to_f
    if denominator > 0.0
      @percentage_outbound_quantity_at_risk = total_inbound_quantity_at_risk(options).to_f/denominator 
    end
    @percentage_outbound_quantity_at_risk
  end

  def deleteable?
    origin_shipment_lines.empty? and destination_shipment_lines.empty? and origin_order_lines.empty? and destination_order_lines.empty? and inventory_positions.empty?
  end

  def housed_products
    @housed_products = []
    order_lines("destination").each {|ol| @housed_products << ol.product unless @housed_products.include?(ol.product) }
    shipment_lines("destination").each {|sl| @housed_products << sl.product unless @housed_products.include?(sl.product)}
    order_lines("origin").each {|ol| @housed_products << ol.product unless @housed_products.include?(ol.product)}
    @housed_products  
  end

  def all_exceptions(options = {}) 
    allexceptions = inbound_shipment_line_exceptions(options)
    allexceptions << inbound_order_line_exceptions(options)
    allexceptions << inventory_exceptions(options) 
    allexceptions << outbound_order_line_exceptions(options)    
    allexceptions.flatten!
    return allexceptions
  end

  def total_exception_quantity(options = {})
    total_excptn_qty = 0
    all_exceptions(options).each {|excptn| total_excptn_qty += excptn.quantity_at_risk}
    return total_excptn_qty
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
