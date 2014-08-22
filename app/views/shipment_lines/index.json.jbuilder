json.array!(@shipment_lines) do |shipment_line|
  json.extract! shipment_line, :id, :shipment_line_number, :quantity, :eta, :etd, :origin_location_id, :destination_location_id, :order_line_id
  json.url shipment_line_url(shipment_line, format: :json)
end
