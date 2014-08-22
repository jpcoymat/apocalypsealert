json.array!(@products) do |product|
  json.extract! product, :id, :name, :code, :category, :organization_id
  json.url product_url(product, format: :json)
end
