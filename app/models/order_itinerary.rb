class OrderItinerary < ActiveRecord::Base

  belongs_to :order_line
  belongs_to :shipment_line

  validates :order_line_id, :shipment_line_id, presence: true
  validates :order_line_id, uniqueness: {scope: :shipment_line_id } 
  validates :leg_number, uniqueness: {scope: [:order_line_id, :shipment_line_id] }

  def find_previous_order_itinerary
    previous_order_itinerary = nil 
    current_itinitenary_count = OrderItinerary.where(order_line: self.order_line).count
    if current_itinitenary_count == 0
      return previous_order_itinerary
    else
      if shipment_line.origin_location == order_line.origin_location
        return previous_order_itinerary
      else 
        previous_order_itinerary = OrderItinerary.where("order_line_id = #{self.order_line_id} and shipment_line_id in (select id from shipment_lines where destination_location_id = #{self.shipment_line.origin_location_id} and next_order_itinerary_id is null").first
        return previous_order_itinerary
      end
    end     
  end

  def set_leg_number
    previous_itinerary = find_previous_order_itinerary
    previous_itinerary.nil ? self.leg_number = 1 : self.leg_number = previous_itinerary.leg_number + 1
    
  end

  def set_previous_order_itinerary
    previous_itinerary = find_previous_order_itinerary
    unless previous_itinerary.nil?
      previous_itinerary.next_order_itinerary_id = self.id
      previous_itinerary.save
    end
  end

  def next_order_itinerary
    @next_order_itinerary = OrderItinerary.where(id: self.next_order_itinerary_id).first
  end

  def next_order_itinerary=(order_itinerary)
    self.next_order_itinerary_id = order_itinerary.try(:id)
  end

  

end
