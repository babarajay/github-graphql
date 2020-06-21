GraphQL::Relay::ConnectionType.default_nodes_field = true

FinalProjectSchema = GraphQL::Schema.define do
  query(Types::QueryType)
  resolve_type ->(_type, _obj, _ctx) {}
end
