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

  def inbound_order_line_exceptions(options = {})
    inbd_order_line_excptns = exceptions("inbound_order_line", options)
    return inbd_order_line_excptns
  end

  def inbound_order_line_exception_quantity(options = {})
    inbd_order_line_excptn_qty = 0
    inbound_order_line_exceptions(options).each {|excptn| inbd_order_line_excptn_qty += excptn.quantity_at_risk}
    return inbd_order_line_excptn_qty
  end

  def inbound_shipment_line_exceptions(options = {})
    inbd_ship_line_excptns = exceptions(" inbound_shipment_line", options)
    return inbd_ship_line_excptns
  end

  def inbound_shipment_line_exception_quantity(options = {})
    inbd_ship_line_excptn_qty = 0
    inbound_shipment_line_exceptions(options).each {|excptn| inbd_ship_line_excptn_qty += excptn.quantity_at_risk}
    return inbd_ship_line_excptn_qty
  end

  def outbound_order_line_exceptions(options = {})
    otbd_order_line_excptns = exceptions("outbound_order_line", options)
    return otbd_order_line_excptns
  end

  def outbound_order_line_exception_quantity(options = {})
    otbd_order_line_excptn_qty = 0
    outbound_order_line_exceptions(options).each {|excptn| otbd_order_line_excptn_qty += excptn.quantity_at_risk}
    return otbd_order_line_excptn_qty
  end

  def outbound_order_shipment_exceptions(options = {})
    otbd_ship_line_excptns = exceptions("outbound_shipment_line", options)
    return otbd_ship_line_excptns
  end

  protected

    def exceptions(exception_type, options = {})
      method_to_call = (exception_type + "_exceptions").to_sym
      exceptions = []
      exception_locations.each {|loc| exceptions << loc.send(method_to_call, options)}
      exceptions.flatten!
      return exceptions
    end
 
end
