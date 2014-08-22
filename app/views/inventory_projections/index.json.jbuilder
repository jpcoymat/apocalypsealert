json.array!(@inventory_projections) do |inventory_projection|
  json.extract! inventory_projection, :id, :location_id, :product_id, :projected_for, :available_quantity
  json.url inventory_projection_url(inventory_projection, format: :json)
end
