class AddNextItinerary < ActiveRecord::Migration

  def change
    add_column :order_itineraries, :next_order_itinerary_id, :integer
  end
end
