# frozen_string_literal: true

require_relative '../test_helper'

class GitHubMatchingTests < Minitest::Test
  def test_finds_github_repo
    project = create_project('valid_github_project.yml')

    assert project.github_project?
    assert_equal 'up-for-grabs/up-for-grabs.net', project.github_owner_name_pair
  end

  def test_ignores_organization
    project = create_project('invalid_github_organization.yml')

    refute project.github_project?
    assert_nil project.github_owner_name_pair
  end

  def test_ignores_external_site
    project = create_project('invalid_external_link.yml')

    refute project.github_project?
    assert_nil project.github_owner_name_pair
  end

  def test_ignores_invalid_link
    project = create_project('invalid_link_not_handled.yml')

    refute project.github_project?
    assert_nil project.github_owner_name_pair
  end

  def test_ignores_gitlab
    project = create_project('invalid_gitlab_link.yml')

    refute project.github_project?
    assert_nil project.github_owner_name_pair
  end

  def create_project(name)
    parent = File.dirname(__dir__)
    full_path = Pathname.new("#{parent}/fixtures/github_matching/#{name}")
    Project.new(name, full_path.to_s)
  end
end
