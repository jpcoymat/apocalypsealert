json.array!(@scv_exceptions) do |scv_exception|
  json.extract! scv_exception, :id, :type, :priority, :status
  json.url scv_exception_url(scv_exception, format: :json)
end
