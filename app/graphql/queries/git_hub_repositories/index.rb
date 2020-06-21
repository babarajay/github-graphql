class Queries::GitHubRepositories::Index < GraphQL::Function
  description 'List GitHubRepositories'

  argument :repo, !types.String
  argument :email, !types.String
  argument :first, types.Int
  argument :last, types.Int
  argument :last, types.Int

  type Types::JsonbType

  def call(_obj, args, _ctx)
    GitHubService.new(args).call
  end
end
