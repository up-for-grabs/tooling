# frozen_string_literal: true

require 'octokit'

# Check using the GitHub API whether the repository is active
class GitHubRepositoryActiveCheck
  def self.run(project)
    owner_and_repo = project.github_owner_name_pair

    unless owner_and_repo
      return {
        reason: 'error',
        error: StandardError.new("Project #{project.relative_path} is not using GitHub")
      }
    end

    rate_limit = client.rate_limit

    return { rate_limited: true } if rate_limit.remaining.zero?

    repo = client.repo owner_and_repo

    return { deprecated: true, reason: 'archived' } if repo.archived

    unless owner_and_repo.casecmp(repo.full_name).zero?
      return {
        deprecated: false,
        reason: 'redirect',
        old_location: owner_and_repo,
        location: repo.full_name
      }
    end

    { deprecated: false }
  rescue Octokit::NotFound
    # The repository no longer exists in the GitHub API
    { deprecated: true, reason: 'missing' }
  rescue StandardError => e
    { deprecated: false, reason: 'error', error: e }
  end

  def self.client
    @client ||= create_client
  end

  def self.create_client
    Octokit::Client.new(access_token: ENV['GITHUB_TOKEN'])
  end

  private_class_method :client, :create_client
end
