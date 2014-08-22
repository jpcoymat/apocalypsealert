json.array!(@location_groups) do |location_group|
  json.extract! location_group, :id, :code, :name, :organization_id
  json.url location_group_url(location_group, format: :json)
end
