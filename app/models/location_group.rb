class LocationGroup < ActiveRecord::Base

  belongs_to :organization
  has_many :locations

  validates :code, :name, presence: true
  validates :name, uniqueness: {scope: :organization_id}
  validates :code, uniqueness: {scope: :organization_id}

  def deleteable?
    locations.empty?
  end

  def exception_locations
    @exception_locations = []
    locations.each do |location|
      @exception_locations << location if location.all_exceptions.count > 0
    end
  end

  def inbound_order_lines(options = {}) 
    order_lines("destination", options)
  end

  def inbound_order_line_quantity(options = {})
    inbd_ol_qty = 0
    inbound_order_lines(options).each {|ol| inbd_ol_qty += ol.quantity}
    return inbd_ol_qty 
  end

  def outbound_order_lines(options = {})
    order_lines("origin", options = {})
  end

  def outbound_order_line_quantity(options = {})
    otbd_ol_qty = 0
    outbound_order_lines(options).each {|ol| otbd_ol_qty  += ol.quantity}
    return otbd_ol_qty
  end
 
  def inbound_shipment_lines(options = {})
    shipment_lines("destination", options) 
  end

  def inbound_shipment_line_quantity(options = {})
    inbd_ship_qty = 0
    inbound_shipment_lines(options).each {|sl| inbd_ship_qty += sl.quantity}
    return inbd_ship_qty
  end

  def outbound_shipments(options = {})
    shipment_lines("origin", options)
  end

  def work_orders(options = {})
    wos = WorkOrder.where("location_id in (select id from locations where location_group_id = #{self.id})")
    wos = wos.where(product_id: options[:product_id]) if options[:product_id]
    wos = wos.where("product_id in (select id from products where product_category_id = #{options[:product_category_id]})") if options[:product_category_id]
    if options[:product_categories]
      list_of_prod_cats = ""
      options[:product_categories].each {|pc| list_of_prod_cats += pc.id.to_s + ","}
      list_of_prod_cats.chop!
      wos = wos.where("product_id in (select id from products where product_category_id in ('#{list_of_prod_cats}'))") 
    end
    return wos
  end 

  def work_order_quantity(options = {})
    wo_qty = 0
    work_orders(options).each {|wo| wo_qty += wo.quantity}
    return wo_qty
  end

  def inventory_projections(options = {})
    ips = InventoryProjection.where("location_id in (select id from locations where location_group_id = #{self.id})")
    ips = ips.where(product_id: options[:product_id]) if options[:product_id]
    ips = ips.where("product_id in (select id from products where product_category_id = #{options[:product_category_id]})") if options[:product_category_id]
    if options[:product_categories]
      list_of_prod_cats = ""
      options[:product_categories].each {|pc| list_of_prod_cats += pc.id.to_s + ","}
      list_of_prod_cats.chop!
      ips = ips.where("product_id in (select id from products where product_category_id in ('#{list_of_prod_cats}'))")
    end
    return ips  
  end

  def inventory_projection_quantity(options = {})
    ip_qty = 0 
    inventory_projections(options).each {|ip| ip_qty += ip.available_quantity}
    return ip_qty
  end

  def source_exceptions(options = {})
    order_line_exceptions("destination", options)   
  end

  def make_exceptions(options = {})
    make_excptns = []
    work_orders(options).each {|wo| make_excptns << wo.affected_scv_exceptions}
    make_excptns.flatten!
    return make_excptns 
  end

  def move_exceptions(options = {})
    shipment_line_exceptions("destination", options)
  end

  def store_exceptions(options = {})
    store_excptns = []
    inventory_projections(options).each {|ip| store_excptns << ip.affected_scv_exceptions}
    store_excptns.flatten!
    return store_excptns
  end

  def deliver_exceptions(options = {})
    order_line_exceptions("origin", options)
  end
 
  def source_exception_quantity(options = {})
    source_excptn_qty = 0
    source_exceptions(options).each {|se| source_excptn_qty += se.quantity_at_risk}
    return source_excptn_qty
  end

  def make_exception_quantity(options = {})
    make_exception_qty = 0 
    make_exceptions(options).each {|se| make_exception_qty += se.quantity_at_risk}
    return make_exception_qty
  end

  def move_exception_quantity(options = {})
    move_exception_qty = 0
    move_exceptions(options).each {|se| move_exception_qty += se.quantity_at_risk}
    return move_exception_qty
  end

  def store_exception_quantity(options = {})
    store_exception_qty = 0
    store_exceptions(options).each {|se| store_exception_qty += se.quantity_at_risk}
    return store_exception_qty
  end

  def deliver_exception_quantity(options = {})
    deliver_exception_qty = 0
    deliver_exceptions(options).each {|se| deliver_exception_qty += se.quantity_at_risk}
    return deliver_exception_qty
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

  def all_exception_quantity(options = {})
    total_excptn_qty = source_exception_quantity(options) + make_exception_quantity(options) +  move_exception_quantity(options) + store_exception_quantity(options) + deliver_exception_quantity(options)
    return total_excptn_qty
  end

  protected

    def exceptions(exception_type, options = {})
      method_to_call = (exception_type + "_exceptions").to_sym
      exceptions = []
      exception_locations.each {|loc| exceptions << loc.send(method_to_call, options)}
      exceptions.flatten!
      return exceptions
    end

    def order_lines(direction, options = {})
      opts = options.clone
      attribute_name = direction + "_location_id"
      order_lines = OrderLine.where("#{attribute_name} in (select id from locations where location_group_id = #{self.id})")
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
  
    def shipment_lines(direction, options = {})
      opts = options.clone
      attribute_name = direction + "_location_id"
      shipment_lines = ShipmentLine.where("#{attribute_name} in (select id from locations where location_group_id = #{self.id})")
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

    def order_line_exceptions(direction, options = {})
      @order_line_exceptions = []
      order_lines(direction, options).each {|ol| @order_line_exceptions << ol.affected_scv_exceptions}
      @order_line_exceptions.flatten!
      @order_line_exceptions
    end
   
    def shipment_line_exceptions(direction, options = {})
      @shipment_line_exceptions = []
      shipment_lines(direction, options).each {|sl| @shipment_line_exceptions << sl.affected_scv_exceptions}
      @shipment_line_exceptions.flatten!
      @shipment_line_exceptions
    end 


end
