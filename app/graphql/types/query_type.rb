Types::QueryType = GraphQL::ObjectType.define do
  name 'QuertType'

  # Repositories
  field :repositories, function: Queries::GitHubRepositories::Index.new
end
