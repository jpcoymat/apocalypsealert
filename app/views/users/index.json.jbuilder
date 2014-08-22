json.array!(@users) do |user|
  json.extract! user, :id, :email, :encrypted_password, :first_name, :last_name, :username, :organization_id
  json.url user_url(user, format: :json)
end
