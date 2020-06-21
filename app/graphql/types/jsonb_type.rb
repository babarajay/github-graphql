Types::JsonbType = GraphQL::ScalarType.define do
  name 'Jsonb'

  coerce_input ->(value, _ctx) { JSON.parse(value.to_json) }
  coerce_result ->(value, _ctx) { JSON.parse(value.to_json) }
end
