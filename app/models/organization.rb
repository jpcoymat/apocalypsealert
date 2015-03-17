class Organization < ActiveRecord::Base

  has_many :locations
  has_many :location_groups
  has_many :products
  has_many :users
  has_many :product_categories

  def suppliers
    suppliers_from_orders = []
    inbound_order_lines.select(:supplier_organization_id).distinct.each {|sup| suppliers_from_orders << sup.supplier_organization_id}
    if suppliers_from_orders.count> 0
      @suppliers = Organization.find(suppliers_from_orders)
    else
      @suppliers = []
    end
    @suppliers
  end

  def customers
    customers_from_orders = []
    outbound_order_lines.select(:customer_organization_id).distinct.each {|cust| customers_from_orders << cust.customer_organization_id}
    if customers_from_orders
      @customers = Organization.find(customers_from_orders)
    else
      @customers = []
    end
    @customers
  end

  def carriers
    carriers_from_shipments = []
    shipment_lines.select(:carrier_organization_id).distinct.each {|carrier| carriers_from_shipments << carrier.carrier_organization_id}
    if carriers_from_shipments
      @carriers = Organization.find(carriers_from_shipments)
    else
      @carriers = []
    end     
    @carriers
  end

  def forwarders
    forwarders_from_shipments = []
    shipment_lines.select(:forwarder_organization_id).distinct.each {|frwd| forwarders_from_shipments << frwd.forwarder_organization_id}
    if 
      @forwarders = Organization.find(forwarders_from_shipments)
    else
      @forwarders = []
    end  
    @forwarders
  end


  def order_lines(options = {})
    @order_lines = OrderLine.where("customer_organization_id = ? or supplier_organization_id = ?", self.id, self.id)
    @order_lines = @order_lines.where(order_type: options[:order_type]) if options[:order_type]
    @order_lines = @order_lines.where(product_id: options[:product_id]) if options[:product_id]
    @order_lines = @order_lines.where("product_id = (select id from products where name = #{options[:product_name]})") if options[:product_name]
    @order_lines = @order_lines.where("product_id in (select id from products where product_category_id = #{options[:product_category_id]})") if options[:product_category_id]
    @order_lines = @order_lines.where("product_id in (select id from products where product_category_id in (#{options[:product_categories]}))") if options[:product_categories]
    @order_lines = @order_lines.where(origin_location_id: options[:origin_location_id]) if options[:origin_location_id]
    @order_lines = @order_lines.where(destination_location_id: options[:destination_location_id]) if options[:destination_location_id]
    @order_lines = @order_lines.where("origin_location_id in (select id from locations where location_group_id = #{options[:origin_location_group_id]})") if options[:origin_location_group_id]
    @order_lines = @order_lines.where("origin_location_id in (select id from locations where location_group_id in (#{options[:origin_location_groups]}))") if options[:origin_location_groups]
    @order_lines = @order_lines.where("destination_location_id in (select id from locations where location_group_id = #{options[:destination_location_group_id]})") if options[:destination_location_group_id]
    @order_lines = @order_lines.where("destination_location_id in (select id from locations where location_group_id in (#{options[:destination_location_groups]}))") if options[:destination_location_groups]
    @order_lines
  end

  def shipment_lines(options = {})
    @shipment_lines = ShipmentLine.where("carrier_organization_id = ? or forwarder_organization_id = ? or customer_organization_id = ?", self.id, self.id, self.id)
    @shipment_lines = @shipment_lines.where(mode: options[:mode]) if options[:mode]
    @shipment_lines = @shipment_lines.where(shipment_type: options[:shipment_type]) if options[:shipment_type]
    @shipment_lines = @shipment_lines.where(product_id: options[:product_id]) if options[:product_id]
    @shipment_lines = @shipment_lines.where("product_id = (select id from products where name = #{options[:product_name]})") if options[:product_name]
    @shipment_lines = @shipment_lines.where("product_id in (select id from products where product_category_id = #{options[:product_category_id]})") if options[:product_category_id]
    @shipment_lines = @shipment_lines.where("product_id in (select id from products where product_category_id in (#{options[:product_categories]}))") if options[:product_categories]
    @shipment_lines = @shipment_lines.where(origin_location_id: options[:origin_location_id]) if options[:origin_location_id]
    @shipment_lines = @shipment_lines.where(destination_location_id: options[:destination_location_id]) if options[:destination_location_id]
    @shipment_lines = @shipment_lines.where("origin_location_id in (select id from locations where location_group_id = #{options[:origin_location_group_id]})") if options[:origin_location_group_id]
    @shipment_lines = @shipment_lines.where("origin_location_id in (select id from locations where location_group_id in (#{options[:origin_location_groups]}))") if options[:origin_location_groups]
    @shipment_lines = @shipment_lines.where("destination_location_id in (select id from locations where location_group_id = #{options[:destination_location_group_id]})") if options[:destination_location_group_id]
    @shipment_lines = @shipment_lines.where("destination_location_id in (select id from locations where location_group_id in (#{options[:destination_location_groups]}))") if options[:destination_location_groups]
    @shipment_lines
    @shipment_lines
  end

  def work_orders(options = {})
    @work_orders = WorkOrder.where(organization_id: self.id)
    @work_orders = @work_orders.where(product_id: options[:product_id]) if options[:product_id]
    @work_orders = @work_orders.where("product_id in (select id from products where product_category_id = #{options[:product_category_id]})") if options[:product_category_id]
    @work_orders = @work_orders.where("product_id in (select id from products where product_category_id in (#{options[:product_categories]}))") if options[:product_categories] 
    @work_orders = @work_orders.where(location_id: options[:location_id]) if options[:location_id]
    @work_orders = @work_orders.where("location_id in (select id from locations where location_group_id = #{options[:location_group_id]})") if options[:location_group_id]
    @work_orders = @work_orders.where("location_id in (select id from locations where location_group_id in (#{options[:location_groups]}))") if options[:location_groups]
    @work_orders
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
    @inbound_order_lines = order_lines({order_type: "Inbound"}.merge(opts))
    @inbound_order_lines
  end

  def inbound_order_quantity(options = {})
    @inbound_order_quantity = inbound_order_lines(options).sum("quantity").to_i
    @inbound_order_quantity
  end

  def outbound_order_lines(options = {})
    opts = options.clone
    opts.delete(:destination_location_id) if opts[:destination_location_id]
    opts.delete(:destination_location_group_id) if opts[:destination_location_group_id]
    opts.delete(:destination_location_groups) if opts[:destination_location_groups]
    @outbound_order_lines = order_lines({order_type: "Outbound"}.merge(opts))
    @outbound_order_lines
  end

  def outbound_order_quantity(options = {})
    @outbound_order_quantity = outbound_order_lines(options).sum("quantity").to_i
    @outbound_order_quantity
  end

  def inbound_shipment_lines(options = {})
    @inbound_shipment_lines = shipment_lines({shipment_type: "Inbound"}.merge(options))
    @inbound_shipment_lines
  end

  def inbound_shipment_quantity(options = {})
    @inbound_shipment_quantity = inbound_shipment_lines(options).sum("quantity").to_i
    @inbound_shipment_quantity
  end

  def outbound_shipment_lines(options = {})
    @outbound_shipment_lines = shipment_lines({shipment_type: "Outbound"}.merge(options))
    @outbound_shipment_lines
  end

  def outbound_shipment_quantity(options = {})
    @outbound_shipment_quantity = outbound_shipment_lines(options).sum("quantity").to_i
    @outbound_shipment_quantity
  end

  def inventory_projections(options = {})
    @inventory_projections = InventoryProjection.where(organization_id: self.id)
    @inventory_projections = @inventory_projections.where(product_id: options[:product_id]) if options[:product_id]
    @inventory_projections = @inventory_projections.where("product_id in (select id from products where product_category_id = #{options[:product_category_id]})") if options[:product_category_id]
    @inventory_projections = @inventory_projections.where("product_id in (select id from products where product_category_id in (#{options[:product_categories]}))") if options[:product_categories]
    @inventory_projections = @inventory_projections.where(location_id: options[:location_id]) if options[:location_id]
    @inventory_projections = @inventory_projections.where("location_id in (select id from locations where location_group_id = #{options[:location_group_id]})") if options[:location_group_id]
    @inventory_projections = @inventory_projections.where("location_id in (select id from locations where location_group_id in (#{options[:location_groups]}))") if options[:location_groups]
    @inventory_projections
  end

  def inventory_projection_quantity(options = {})
    @inventory_projection_quantity = inventory_projections(options).sum("available_quantity").to_i
    @inventory_projection_quantity
  end

  def source_exceptions(options = {})
    order_line_ids = inbound_order_lines(options).ids.to_s.chop![1..-1]
    if order_line_ids == ""
      @source_exceptions = nil
    else
      @source_exceptions = ScvException.where("affected_object_type = 'OrderLine' and affected_object_id in (#{order_line_ids})")
    end
    @source_exceptions 
  end

  def source_exception_quantity(options = {}) 
    exceptions = source_exceptions(options)
    if exceptions.nil?
      @source_exception_quantity = 0
    else 
      @source_exception_quantity = exceptions.sum("abs(affected_object_quantity - cause_object_quantity)").to_i
    end
    @source_exception_quantity
  end

  def make_exceptions(options ={})
    wo_ids = work_orders(options).ids.to_s.chop![1..-1]
    if wo_ids == ""
      @make_exceptions = nil
    else
      @make_exceptions = ScvException.where("affected_object_type = 'WorkOrder' and affected_object_id in (#{wo_ids})")
    end
    @make_exceptions
  end

  def make_exception_quantity(options = {})
    exceptions = make_exceptions(options)
    if exceptions.nil?
      @make_exception_quantity = 0
    else 
      @make_exception_quantity = exceptions.sum("abs(affected_object_quantity - cause_object_quantity)").to_i
    end
    @make_exception_quantity
  end

  def move_exceptions(options = {})
    ship_ids = shipment_lines(options).ids.to_s.chop![1..-1] 
    if ship_ids == ""
      @move_exceptions = nil
    else
      @move_exceptions = ScvException.where("affected_object_type = 'ShipmentLine' and affected_object_id in (#{ship_ids})")
    end
    @move_exceptions
  end

  def move_exception_quantity(options = {})
    exceptions = move_exceptions(options)
    if exceptions.nil?
      @move_exception_quantity = 0
    else
      @move_exception_quantity = exceptions.sum("abs(affected_object_quantity - cause_object_quantity)").to_i 
    end
    @move_exception_quantity
  end

  def store_exceptions(options = {})
    ip_ids = inventory_projections(options).ids.to_s.chop![1..-1]
    if ip_ids == ""
      @store_exceptions = nil
    else
      @store_exceptions = ScvException.where("affected_object_type = 'InventoryProjection' and affected_object_id in (#{ip_ids})")
    end
    @store_exceptions
  end

  def store_exception_quantity(options = {})
    exceptions = store_exceptions(options)
    if exceptions.nil?
      @store_exception_quantity = 0
    else
      @store_exception_quantity = exceptions.sum("abs(affected_object_quantity - cause_object_quantity)").to_i
    end
    @store_exception_quantity
  end

  def deliver_exceptions(options = {})
    order_ids = outbound_order_lines(options).ids.to_s.chop![1..-1]
    if order_ids == ""
      @deliver_exceptions = nil
    else
      @deliver_exceptions = ScvException.where("affected_object_type = 'OrderLine' and affected_object_id in (#{order_ids})")
    end
    @deliver_exceptions
  end

  def deliver_exception_quantity(options = {})
    exceptions = deliver_exceptions(options)
    if exceptions.nil?
      @deliver_exception_quantity = 0
    else
      @deliver_exception_quantity = exceptions.sum("abs(affected_object_quantity - cause_object_quantity)").to_i
    end
    @deliver_exception_quantity
  end

  def deleteable?
    if locations.empty? and location_groups.empty? and products.empty? and users.empty? and product_categories.empty?
      if order_lines.empty? and shipment_lines.empty?
         return true
      else
        return false
      end
    else
      return false
    end
  end

  def exception_locations
    @exception_locations = []
    locations.each do |location|
      @exception_locations << location if location.has_exception?
    end 
    @exception_locations
  end

end
