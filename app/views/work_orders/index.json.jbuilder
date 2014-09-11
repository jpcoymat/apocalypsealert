json.array!(@work_orders) do |work_order|
  json.extract! work_order, :id, :work_order_number, :product_id, :location_id, :production_date, :quantity, :organization_id
  json.url work_order_url(work_order, format: :json)
end
