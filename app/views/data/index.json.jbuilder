json.array!(@data) do |datum|
  json.extract! datum, :id, :key, :value
  json.url datum_url(datum, format: :json)
end
