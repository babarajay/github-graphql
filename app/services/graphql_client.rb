require "graphql/client"
require "graphql/client/http"

module GraphqlClient
  GITHUB_ACCESS_TOKEN = Rails.application.credentials.github_token
  URL = Rails.application.credentials.github_base_url

  HttpAdapter = GraphQL::Client::HTTP.new(URL) do
    def headers(context)
      {
        "Authorization" => "Bearer #{GITHUB_ACCESS_TOKEN}",
        "User-Agent" => 'Ruby'
      }
    end
  end

  Schema = GraphQL::Client.load_schema(HttpAdapter)
  Client = GraphQL::Client.new(schema: Schema, execute: HttpAdapter)
end