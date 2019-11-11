# frozen_string_literal: true

# Check using the GitHub API whether the label in a repository is active
module GitHubRepositoryLabelActiveCheck
  def self.parse(result)
    repository = result.data.repository

    # we should be checking for repository existence before this, but flag it anyway
    return { reason: 'repository-missing' } if repository.nil?

    return { reason: 'missing' } if repository.label.nil?

    label = repository.label
    count = label.issues.total_count
    last_updated = label.issues.nodes[0].updated_at

    { reason: 'found', name: label.name, url: label.url, count: count, last_updated: last_updated }
  end

  def self.run(project)
    owner_and_repo = project.github_owner_name_pair

    unless owner_and_repo
      return {
        reason: 'error',
        error: StandardError.new("Project #{project.relative_path} is not using GitHub")
      }
    end

    result = client.query(RateLimitQuery)

    return { rate_limited: true } if result.data.rate_limit.remaining.zero?

    items = owner_and_repo.split('/')
    owner = items[0]
    name = items[1]

    yaml = project.read_yaml
    label = yaml['upforgrabs']['name']

    variables = { owner: owner, name: name, label: label }

    parse(client.query(IssueCountForLabel, variables: variables))
  rescue StandardError => e
    { reason: 'error', error: e }
  end

  def self.client
    @client ||= create_client
  end

  def self.create_client
    http = GraphQL::Client::HTTP.new('https://api.github.com/graphql') do
      def headers(_context)
        # Optionally set any HTTP headers
        {
          "User-Agent": 'up-for-grabs-graphql-label-queries',
          "Authorization": "bearer #{ENV['GITHUB_TOKEN']}"
        }
      end
    end

    schema = GraphQL::Client.load_schema(http)

    client = GraphQL::Client.new(schema: schema, execute: http)

    self.class.RateLimitQuery = client.parse <<-'GRAPHQL'
      {
        rateLimit {
          remaining
        }
      }
    GRAPHQL

    self.class.IssueCountForLabel = client.parse <<-'GRAPHQL'
      query($owner: String!, $name: String!, $label: String!) {
        repository(owner: $owner, name: $name) {
          label(name: $label) {
            name
            url
            issues(states: OPEN, first: 2, orderBy: {field: UPDATED_AT, direction: DESC}) {
              totalCount
              nodes {
                number
                updatedAt
              }
            }
          }
        }
        rateLimit {
          limit
          cost
          remaining
          resetAt
        }
      }
    GRAPHQL

    client
  end

  private_class_method :client, :create_client
end
