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
    workorders = workorders.where("location_id in (select id from locations where location_group_id in (#{opts[:location_groups]}))") if opts[:location_groups]
    return workorders
  end

  def work_order_quantity(options = {})
    @work_order_quantity = work_orders(options).sum("quantity").to_i
    @work_order_quantity
  end

  def inbound_order_lines(options = {})
    opts = options.clone
    opts.delete(:origin_location_id) if opts[:origin_location_id]
    opts.delete(:origin_location_group_id) if opts[:origin_location_group_id]
    opts.delete(:origin_location_groups) if opts[:origin_location_groups]
    inbd_ols = order_lines({order_type: "Inbound"}.merge(opts))
    return inbd_ols
  end

  def inbound_order_line_quantity(options= {})
    @inbound_order_line_quantity = inbound_order_lines(options).sum("quantity").to_i
    @inbound_order_line_quantity
  end

  def outbound_order_lines(options = {})
    opts = options.clone
    opts.delete(:destination_location_id) if opts[:destination_location_id]
    opts.delete(:destination_location_group_id) if opts[:destination_location_group_id]
    opts.delete(:destination_location_groups) if opts[:destination_location_groups]
    ob_ols = order_lines({order_type: "Outbound"}.merge(opts))
    return ob_ols
  end 

  def outbound_order_line_quantity(options = {})
    @outbound_order_line_quantity = outbound_order_lines(options).sum("quantity").to_i
    @outbound_order_line_quantity
  end

  def inbound_shipment_lines(options = {})
    opts = options.clone
    opts.delete(:origin_location_id) if opts[:origin_location_id]
    opts.delete(:origin_location_group_id) if opts[:origin_location_group_id]
    opts.delete(:origin_location_groups) if opts[:origin_location_groups]
    inbd_shpmts = shipment_lines({shipment_type: "Inbound"}.merge(opts))
    return inbd_shpmts 
  end

  def inbound_shipment_line_quantity(options = {})
    @inbound_shipment_line_quantity = inbound_shipment_lines(options).sum("quantity").to_i
    @inbound_shipment_line_quantity
  end

  def outbound_shipment_lines(options = {})
    opts = options.clone
    opts.delete(:destination_location_id) if opts[:destination_location_id]
    opts.delete(:destination_location_group_id) if opts[:destination_location_group_id]
    opts.delete(:destination_location_groups) if opts[:destination_location_groups]
    otbd_shpmts =  shipment_lines({shipment_type: "Outbound"}.merge(opts))
    return otbd_shpmts
  end

  def outbound_shipment_line_quantity(options = {})
    @outbound_shipment_line_quantity = outbound_shipment_lines(options).sum("quantity").to_i
  end

  def inventory_projections(options = {})
    opts = options.clone
    projections = InventoryProjection.where("product_id in (select id from products where product_category_id = #{self.id})")
    projections = projections.where(location_id: opts[:location_id]) if opts[:location_id]
    projections = projections.where("location_id in (select id from locations where location_group_id = #{opts[:location_group_id]})") if opts[:location_group_id]
    if opts[:location_groups]
      projections = projections.where("location_id in (select id from locations where location_group_id in (#{opts[:location_groups]}))")
    end
    return projections
  end

  def inventory_projection_quantity(options = {})
    @inventory_projection_quantity = inventory_projections(options).sum("available_quantity").to_i
    @inventory_projection_quantity
  end

  def source_exceptions(options = {})
    opts = options.clone
    opts.delete(:origin_location_id) if opts[:origin_location_id]
    opts.delete(:origin_location_group_id) if opts[:origin_location_group_id]
    opts.delete(:origin_location_groups) if opts[:origin_location_groups]
    order_line_exceptions({order_type: "Inbound"}.merge(opts))
  end

  def source_exception_quantity(options = {})
    @source_exception_quantity = source_exceptions(options).sum("abs(affected_object_quantity - cause_object_quantity)").to_i
    @source_exception_quantity
  end

  def make_exceptions(options = {})
    work_order_ids = work_orders(options).ids.to_s.chop![1..-1]
    work_order_ids = "-1" if (work_order_ids.nil? or work_order_ids == "")
    @work_order_exceptions = ScvException.where("affected_object_type = 'WorkOrder' and affected_object_id in (#{work_order_ids})") 
    @work_order_exceptions
  end

  def make_exception_quantity(options = {})
    @make_exception_quantity = make_exceptions(options).sum("abs(affected_object_quantity - cause_object_quantity)").to_i
    @make_exception_quantity
  end

  def move_exceptions(options = {})
    opts = options.clone
    opts.delete(:origin_location_id) if opts[:origin_location_id]
    opts.delete(:origin_location_group_id) if opts[:origin_location_group_id]
    opts.delete(:origin_location_groups) if opts[:origin_location_groups]
    shipment_line_exceptions({shipment_type: "Inbound"}.merge(opts)) 
  end
  
  def move_exception_quantity(options = {})
    @move_exception_quantity = move_exceptions(options).sum("abs(affected_object_quantity - cause_object_quantity)").to_i
    @move_exception_quantity
  end

  def store_exceptions(options = {})
    project_ids = inventory_projections(options).ids.to_s.chop![1..-1]
    project_ids = "-1" if (project_ids.nil? or project_ids == "")
    @store_exceptions = ScvException.where("affected_object_type = 'InventoryProjection' and affected_object_id in (#{project_ids})")
    @store_exceptions 
  end

  def store_exception_quantity(options = {})
    @store_exception_quantity = store_exceptions(options).sum("abs(affected_object_quantity - cause_object_quantity)").to_i
    @store_exception_quantity
  end 

  def deliver_exceptions(options = {})
    opts = options.clone
    opts.delete(:destination_location_id) if opts[:destination_location_id]
    opts.delete(:destination_location_group_id) if opts[:destination_location_group_id]
    opts.delete(:destination_location_groups) if opts[:destination_location_groups]
    order_line_exceptions({order_type: "Outbound"}.merge(opts)) 
  end

  def deliver_exception_quantity(options = {})
    @deliver_exception_quantity = deliver_exceptions(options).sum("abs(affected_object_quantity - cause_object_quantity)").to_i
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
      orderlines = orderlines.where("origin_location_id in (select id from locations where location_group_id in (#{opts[:origin_location_groups]}))") if opts[:origin_location_groups]
      orderlines = orderlines.where("destination_location_id in (select id from locations where location_group_id = #{opts[:destination_location_group_id]})") if opts[:destination_location_group_id]
      orderlines = orderlines.where("destination_location_id in (select id from locations where location_group_id in (#{opts[:destination_location_groups]}))") if opts[:destination_location_groups]
      return orderlines
    end

    def shipment_lines(options = {})
      opts = options.clone
      shipmentlines = ShipmentLine.where("product_id in (select id from products where product_category_id = #{self.id})")
      shipmentlines = shipmentlines.where(shipment_type: opts[:shipment_type]) if opts[:shipment_type]
      shipmentlines = shipmentlines.where(origin_location_id: opts[:origin_location_id]) if opts[:origin_location_id]
      shipmentlines = shipmentlines.where(destination_location_id: opts[:destination_location_id]) if opts[:destination_location_id]
      shipmentlines = shipmentlines.where("origin_location_id in (select id from locations where location_group_id = #{opts[:origin_location_group_id]})") if opts[:origin_location_group_id]
       shipmentlines = shipmentlines.where("origin_location_id in (select id from locations where location_group_id in (#{opts[:origin_location_groups]}))") if opts[:origin_location_groups]
      shipmentlines = shipmentlines.where("destination_location_id in (select id from locations where location_group_id = #{opts[:destination_location_group_id]})") if opts[:destination_location_group_id]
      shipmentlines = shipmentlines.where("destination_location_id in (select id from locations where location_group_id in (#{opts[:destination_location_groups]}))") if opts[:destination_location_groups]
      return shipmentlines
    end

    def order_line_exceptions(options = {})
      order_line_ids = order_lines(options).ids.to_s.chop![1..-1]
      order_line_ids = "-1" if (order_line_ids.nil? or order_line_ids == "")
      @order_line_exceptions = ScvException.where("affected_object_type = 'OrderLine' and affected_object_id in (#{order_line_ids})")
      @order_line_exceptions
    end

    def shipment_line_exceptions(options = {})
      ship_line_ids =  shipment_lines(options).ids.to_s.chop![1..-1]
      ship_line_ids = "-1" if (ship_line_ids.nil? or ship_line_ids == "")
      @shipment_line_exceptions = ScvException.where("affected_object_type = 'ShipmentLine' and affected_object_id in (#{ship_line_ids})")
      @shipment_line_exceptions
    end
   

end
