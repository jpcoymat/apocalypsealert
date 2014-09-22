class ProductCategory < ActiveRecord::Base

  belongs_to :organization

  has_many :products
  validates :name, :organization_id, presence: true
  validates :name, uniqueness: {scope: :organization_id}

  def deleteable?
    products.empty?
  end
   
  def work_orders(options = {})
    opts = options.clone
    opts.delete(:destination_location_id) if opts[:destination_location_id]
    opts.delete(:destination_location_group_id) if opts[:destination_location_group_id]
    opts.delete(:destination_location_groups) if opts[:destination_location_groups]
    opts.delete(:origin_location_id) if opts[:origin_location_id]
    opts.delete(:origin_location_group_id) if opts[:origin_location_group_id]
    opts.delete(:origin_location_groups) if opts[:origin_location_groups]
    workorders = WorkOrder.where("product_id in (select id from products where product_category_id = #{self.id})")
    workorders = workorders.where(location_id: opts[:location_id]) if opts[:location_id]
    workorders = workorders.where("location_id in (select id from locations where location_group_id = #{opts[:location_group_id]})") if opts[:location_group_id]
    if opts[:location_groups]
      list_of_grp_ids = ""
      opts[:location_groups].each {|lg| list_of_grp_ids += lg.to_s + ","}
      list_of_grp_ids.chop!
      workorders = workorders.where("location_id in (select id from locations where location_group_id in (#{list_of_grp_ids}))")
    end
    return workorders
  end

  def work_order_quantity(options = {})
    wo_qty = 0
    work_orders(options).each {|wo| wo_qty += wo.quantity}
    return wo_qty  
  end

  def inbound_order_lines(options = {})
    inbd_ols = order_lines({order_type: "Inbound"}.merge(options))
    return inbd_ols
  end

  def inbound_order_line_quantity(options= {})
    inbd_ol_qty = 0
    inbound_order_lines(options).each {|ol| inbd_ol_qty += ol.quantity}
    return inbd_ol_qty
  end

  def outbound_order_lines(options = {})
    ob_ols = order_lines({order_type: "Outbound"}.merge(options))
    return ob_ols
  end 

  def outbound_order_line_quantity(options = {})
    otbd_ol_qty = 0
    outbound_order_lines(options).each {|ol| otbd_ol_qty += ol.quantity}
    return otbd_ol_qty
  end

  def inbound_shipment_lines(options = {})
    inbd_shpmts = shipment_lines({shipment_type: "Inbound"}.merge(options))
    return inbd_shpmts 
  end

  def inbound_shipment_line_quantity(options = {})
    inbd_sl_qty = 0
    inbound_shipment_lines(options).each {|sl| inbd_sl_qty += sl.quantity}
    return inbd_sl_qty
  end

  def outbound_shipment_lines(options = {})
    otbd_shpmts =  shipment_lines({shipment_type: "Outbound"}.merge(options))
    return otbd_shpmts
  end

  def outbound_shipment_line_quantity(options = {})
    otbd_sl_qty = 0
    outbound_shipment_lines(options).each {|sl| otbd_sl_qty += sl.quantity}
    return otbd_sl_qty
  end

  def inventory_projections(options = {})
    opts = options.clone
    projections = InventoryProjection.where("product_id in (select id from products where product_category_id = #{self.id})")
    projections = projections.where(location_id: opts[:location_id]) if opts[:location_id]
    projections = projections.where("location_id in (select id from locations where location_group_id = #{opts[:location_group_id]})") if opts[:location_group_id]
    if opts[:location_groups]
      list_of_grp_ids = ""
      opts[:location_groups].each {|lg| list_of_grp_ids += lg.to_s + ","}
      list_of_grp_ids.chop!
      projections = projections.where("location_id in (select id from locations where location_group_id in (#{list_of_grp_ids}))")
    end
    return projections
  end

  def inventory_projection_quantity(options = {})
    inv_qty = 0
    inventory_projections(options).each {|ip| inv_qty += ip.available_quantity}
    return inv_qty
  end

  def source_exceptions(options = {})
    opts = options.clone
    opts.delete(:origin_location_id) if opts[:origin_location_id]
    opts.delete(:origin_location_group_id) if opts[:origin_location_group_id]
    opts.delete(:origin_location_groups) if opts[:origin_location_groups]
    order_line_exceptions({order_type: "Inbound"}.merge(opts))
  end

  def source_exception_quantity(options = {})
    srce_excptn_qty = 0
    source_exceptions(options).each {|se| srce_excptn_qty += se.quantity_at_risk}
    return srce_excptn_qty
  end

  def make_exceptions(options = {})
    make_excptns = [] 
    work_orders(options).each {|wo| make_excptns << wo.affected_scv_exceptions}
    make_excptns.flatten!
    return make_excptns
  end

  def make_exception_quantity(options = {})
    make_excptn_qty = 0
    make_exceptions(options).each {|se| make_excptn_qty += se.quantity_at_risk}
    return make_excptn_qty
  end

  def move_exceptions(options = {})
    opts = options.clone
    opts.delete(:origin_location_id) if opts[:origin_location_id]
    opts.delete(:origin_location_group_id) if opts[:origin_location_group_id]
    opts.delete(:origin_location_groups) if opts[:origin_location_groups]
    shipment_line_exceptions({shipment_type: "Inbound"}.merge(opts)) 
  end
  
  def move_exception_quantity(options = {})
    move_excptn_qty = 0
    move_exceptions(options).each {|se| move_excptn_qty += se.quantity_at_risk}
    return move_excptn_qty
  end

  def store_exceptions(options = {})
    store_excptns = []
    inventory_projections(options).each {|ip| store_excptns << ip.affected_scv_exceptions}
    store_excptns.flatten!
    return store_excptns
  end

  def store_exception_quantity(options = {})
    store_excptn_qty = 0
    store_exceptions(options).each {|se| store_excptn_qty += se.quantity_at_risk}
    return store_excptn_qty
  end 

  def deliver_exceptions(options = {})
    opts = options.clone
    opts.delete(:destination_location_id) if opts[:destination_location_id]
    opts.delete(:destination_location_group_id) if opts[:destination_location_group_id]
    opts.delete(:destination_location_groups) if opts[:destination_location_groups]
    order_line_exceptions({order_type: "Outbound"}.merge(opts)) 
  end

  def deliver_exception_quantity(options = {})
    dlvr_excptn_qty = 0
    deliver_exceptions(options).each {|se| dlvr_excptn_qty += se.quantity_at_risk}
    return dlvr_excptn_qty
  end 


  def all_exceptions(options = {})
    all_excptns = source_exceptions(options)
    all_excptns << make_exceptions(options)
    all_excptns << move_exceptions(options)
    all_excptns << store_exceptions(options)
    all_excptns << deliver_exceptions(options)
    all_excptns.flatten!
    return all_excptns
  end

  def all_exception_quantity(options = {})
    total_exception_qty = source_exception_quantity(options) + make_exception_quantity(options) + move_exception_quantity(options) + store_exception_quantity(options) + deliver_exception_quantity(options)
    return total_exception_qty
  end

  protected  

    def order_lines(options = {})
      opts = options.clone
      orderlines = OrderLine.where("product_id in (select id from products where product_category_id = #{self.id})")
      orderlines = orderlines.where(order_type: opts[:order_type]) if opts[:order_type]
      orderlines = orderlines.where(origin_location_id: opts[:origin_location_id]) if opts[:origin_location_id]
      orderlines = orderlines.where(destination_location_id: opts[:destination_location_id]) if opts[:destination_location_id]
      orderlines = orderlines.where("origin_location_id in (select id from locations where location_group_id = #{opts[:origin_location_group_id]})") if opts[:origin_location_group_id]
      if opts[:origin_location_groups]
       list_of_grp_ids = ""
       opts[:origin_location_groups].each {|lg| list_of_grp_ids += lg.to_s + ","}
       list_of_grp_ids.chop!
       orderlines = orderlines.where("origin_location_id in (select id from locations where location_group_id in (#{list_of_grp_ids}))")
      end      
      orderlines = orderlines.where("destination_location_id in (select id from locations where location_group_id = #{opts[:destination_location_group_id]})") if opts[:destination_location_group_id]
      if opts[:destination_location_groups]
       list_of_grp_ids = ""
       opts[:destination_location_groups].each {|lg| list_of_grp_ids += lg.to_s + ","}
       list_of_grp_ids.chop!
       orderlines = orderlines.where("destination_location_id in (select id from locations where location_group_id in (#{list_of_grp_ids}))")
      end
      return orderlines
    end

    def shipment_lines(options = {})
      opts = options.clone
      shipmentlines = ShipmentLine.where("product_id in (select id from products where product_category_id = #{self.id})")
      shipmentlines = shipmentlines.where(shipment_type: opts[:shipment_type]) if opts[:shipment_type]
      shipmentlines = shipmentlines.where(origin_location_id: opts[:origin_location_id]) if opts[:origin_location_id]
      shipmentlines = shipmentlines.where(destination_location_id: opts[:destination_location_id]) if opts[:destination_location_id]
      shipmentlines = shipmentlines.where("origin_location_id in (select id from locations where location_group_id = #{opts[:origin_location_group_id]})") if opts[:origin_location_group_id]
      if opts[:origin_location_groups]
       list_of_grp_ids = ""
       opts[:origin_location_groups].each {|lg| list_of_grp_ids += lg.to_s + ","}
       list_of_grp_ids.chop!
       shipmentlines = shipmentlines.where("origin_location_id in (select id from locations where location_group_id in (#{list_of_grp_ids}))")
      end
      shipmentlines = shipmentlines.where("destination_location_id in (select id from locations where location_group_id = #{opts[:destination_location_group_id]})") if opts[:destination_location_group_id]
      if opts[:destination_location_groups]
       list_of_grp_ids = ""
       opts[:destination_location_groups].each {|lg| list_of_grp_ids += lg.to_s + ","}
       list_of_grp_ids.chop!
       shipmentlines = shipmentlines.where("destination_location_id in (select id from locations where location_group_id in (#{list_of_grp_ids}))")
      end
      return shipmentlines
    end

    def order_line_exceptions(options = {})
      @order_line_exceptions = []
      order_lines(options).each {|order_line| @order_line_exceptions << order_line.affected_scv_exceptions}
      @order_line_exceptions.flatten!
      @order_line_exceptions
    end

    def shipment_line_exceptions(options = {})
      @shipment_line_exceptions = []
      shipment_lines(options).each {|ship_line| @shipment_line_exceptions << ship_line.affected_scv_exceptions}
      @shipment_line_exceptions.flatten!
      @shipment_line_exceptions
    end
   

end
