class GitHubService
  attr_accessor :repo, :first, :last, :response, :email

  AllRepositoryQuery = GraphqlClient::Client.parse <<-'GRAPHQL'
    query($login: String!, $first: Int, $last: Int){
      repositoryOwner(login: $login){
        repositories(first: $first, last: $last){
          edges{
            node{
              name
              createdAt
              primaryLanguage{
                name
              }
            }
          }
        }
      }
    }
  GRAPHQL

  def initialize(args)
    @repo = args[:repo]
    @first = args[:first]
    @last = args[:last]
    @email = args[:email]
    @response = nil
  end

  def call
    @response = execute_github_graphql_api
    send_email_with_csv
    analyze_languages
  end

  private

  def send_email_with_csv
    require 'csv'
    timestamp = Time.now.to_i
    file = "#{Rails.root}/tmp/#{timestamp}.csv"
    headers = ["Name", "Language", "createdAt"]
    repositories = JSON.parse(response.to_json)
    CSV.open(file, 'w', write_headers: true, headers: headers) do |writer|
      repositories['data']['edges'].each do |repo|
        language = repo['node']['primaryLanguage'] ? repo['node']['primaryLanguage']['name'] : ''
        writer << [repo['node']['name'], language, repo['node']['createdAt']]
      end
    end
    ApplicationMailer.send_csv(email, timestamp).deliver
  end

  def analyze_languages
    repositories = JSON.parse(response.to_json)
    repositories['data']['edges'].reject!{ |repo| repo['node']['primaryLanguage'].nil? }
    languages = repositories['data']['edges'].group_by{|h| h["node"]["primaryLanguage"]["name"]}.sort_by{|key, value| value.count}.map{|lang| { "#{lang[0]}" => lang[1].count } }

    repositories.merge!({ "most_used_languages" => languages[languages.length - 5, languages.length].reverse, "least_used_languages" => languages[0, 5].reverse })
  end

  def execute_github_graphql_api
    response = GraphqlClient::Client.query(AllRepositoryQuery, variables: { login: repo, first: first, last: last })
    if response.errors.any?
      raise GraphQL::ExecutionError.new(response.errors[:data].join(", "))
    else
      response.data.repository_owner.repositories
    end
  end
end
