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
    @inbound_order_line_quantity = inbound_order_lines(options).sum("quantity").to_i
    @inbound_order_line_quantity
  end

  def outbound_order_lines(options = {})
    order_lines("origin", options = {})
  end

  def outbound_order_line_quantity(options = {})
    @outbound_order_line_quantity = outbound_order_lines(options).sum("quantity").to_i
    @outbound_order_line_quantity
  end
 
  def inbound_shipment_lines(options = {})
    shipment_lines("destination", options) 
  end

  def inbound_shipment_line_quantity(options = {})
    @inbound_shipment_line_quantity = inbound_shipment_lines(options).sum("quantity").to_i
    @inbound_shipment_line_quantity
  end

  def outbound_shipments(options = {})
    shipment_lines("origin", options)
  end

  def work_orders(options = {})
    @work_orders = WorkOrder.where("location_id in (select id from locations where location_group_id = #{self.id})")
    @work_orders = @work_orders.where(product_id: options[:product_id]) if options[:product_id]
    @work_orders = @work_orders.where("product_id in (select id from products where product_category_id = #{options[:product_category_id]})") if options[:product_category_id]
    @work_orders = @work_orders.where("product_id in (select id from products where product_category_id in (#{ options[:product_categories]}))") if options[:product_categories]
    @work_orders
  end 

  def work_order_quantity(options = {})
    @work_order_quantity = work_orders(options).sum("quantity").to_i
    @work_order_quantity
  end

  def inventory_projections(options = {})
    @inventory_projections = InventoryProjection.where("location_id in (select id from locations where location_group_id = #{self.id})")
    @inventory_projections = @inventory_projections.where(product_id: options[:product_id]) if options[:product_id]
    @inventory_projections = @inventory_projections.where("product_id in (select id from products where product_category_id = #{options[:product_category_id]})") if options[:product_category_id]
    @inventory_projections = @inventory_projections.where("product_id in (select id from products where product_category_id in (#{options[:product_categories]}))") if options[:product_categories]
    @inventory_projections 
  end

  def inventory_projection_quantity(options = {})
    @inventory_projection_quantity = inventory_projections(options).sum("available_quantity").to_i
    @inventory_projection_quantity
  end

  def source_exceptions(options = {})
    order_line_exceptions("destination", options)   
  end

  def make_exceptions(options = {})
    wo_ids = work_orders(options).ids.to_s.chop![1..-1]
    wo_ids = "-1" if (wo_ids.nil? or wo_ids == "")
    @make_exceptions = ScvException.where("affected_object_type = 'WorkOrder' and affected_object_id in (#{wo_ids})")
    @make_exceptions
  end

  def move_exceptions(options = {})
    shipment_line_exceptions("destination", options)
  end

  def store_exceptions(options = {})
    proj_ids = inventory_projections(options).ids.to_s.chop![1..-1]
    proj_ids = "-1" if (proj_ids.nil? or proj_ids == "")
    @store_exceptions = ScvException.where("affected_object_type = 'InventoryProjection' and affected_object_id in (#{proj_ids})")
    @store_exceptions
  end

  def deliver_exceptions(options = {})
    order_line_exceptions("origin", options)
  end
 
  def source_exception_quantity(options = {})
    @source_exception_quantity = source_exceptions(options).sum("abs(affected_object_quantity - cause_object_quantity)").to_i
    @source_exception_quantity
  end

  def make_exception_quantity(options = {})
    @make_exception_quantity = make_exceptions(options).sum("abs(affected_object_quantity - cause_object_quantity)").to_i
    @make_exception_quantity
  end

  def move_exception_quantity(options = {})
    @move_exception_quantity = move_exceptions(options).sum("abs(affected_object_quantity - cause_object_quantity)").to_i
    @move_exception_quantity
  end

  def store_exception_quantity(options = {})
    @store_exception_quantity = store_exceptions(options).sum("abs(affected_object_quantity - cause_object_quantity)").to_i
    @store_exception_quantity
  end

  def deliver_exception_quantity(options = {})
    @deliver_exception_quantity = deliver_exceptions(options).sum("abs(affected_object_quantity - cause_object_quantity)").to_i
    @deliver_exception_quantity
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
      order_lines = order_lines.where("product_id in (select id from products where product_category_id in (#{opts[:product_categories]}))") if opts[:product_categories]
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
      shipment_lines = shipment_lines.where("product_id in (select id from products where product_category_id in (#{opts[:product_categories]}))") if opts[:product_categories]
      return shipment_lines
    end

    def order_line_exceptions(direction, options = {})
      order_line_ids = order_lines(direction, options).ids.to_s.chop![1..-1]
      order_line_ids = "-1" if (order_line_ids.nil? or order_line_ids == "")
      @order_line_exceptions = ScvException.where("affected_object_type = 'OrderLine' and affected_object_id in (#{order_line_ids})")
      @order_line_exceptions
    end
   
    def shipment_line_exceptions(direction, options = {})
      ship_line_ids = shipment_lines(direction, options).ids.to_s.chop![1..-1]
      ship_line_ids = "-1" if (ship_line_ids.nil? or ship_line_ids == "")
      @shipment_line_exceptions  = ScvException.where("affected_object_type = 'ShipmentLine' and affected_object_id in (#{ship_line_ids})")
      @shipment_line_exceptions
    end 


end
