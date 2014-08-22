json.array!(@locations) do |location|
  json.extract! location, :id, :name, :code, :address, :city, :state_providence, :country, :postal_code, :latitude, :longitude, :organization_id, :location_group_id
  json.url location_url(location, format: :json)
end
