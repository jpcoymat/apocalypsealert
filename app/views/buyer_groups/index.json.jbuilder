json.array!(@buyer_groups) do |buyer_group|
  json.extract! buyer_group, :id, :organization_id, :name, :description
  json.url buyer_group_url(buyer_group, format: :json)
end
