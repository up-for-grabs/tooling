# frozen_string_literal: true

require 'date'
require 'octokit'

YEAR_IN_SECONDS = 60 * 60 * 24 * 365

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

    return { deprecated: true, reason: 'issues-disabled' } unless repo.has_issues

    unless owner_and_repo.casecmp(repo.full_name).zero?
      return {
        deprecated: false,
        reason: 'redirect',
        old_location: owner_and_repo,
        location: repo.full_name
      }
    end

    five_years_ago = Time.now - (3 * YEAR_IN_SECONDS)
    repo_last_updated = repo.updated_at

    if repo_last_updated < five_years_ago
      return { deprecated: false, reason: 'lack-of-activity', last_updated: repo.updated_at }
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
    Octokit::Client.new(access_token: ENV.fetch('GITHUB_TOKEN', nil))
  end

  private_class_method :client, :create_client
end
