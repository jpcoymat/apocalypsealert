json.array!(@order_lines) do |order_line|
  json.extract! order_line, :id, :order_line_number, :quantity, :eta, :etd, :origin_location_id, :destination_location_id
  json.url order_line_url(order_line, format: :json)
end
