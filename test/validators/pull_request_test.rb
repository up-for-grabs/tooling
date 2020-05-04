# frozen_string_literal: true

require_relative '../test_helper'

class PullRequestValidatorTests < Minitest::Test
  def test_one_file_is_good_to_merge
    dir = get_test_directory('one-file')
    files = get_files_in_directory('one-file')

    # stub these calls that depend on the GitHub API
    GitHubRepositoryActiveCheck
      .expects(:run)
      .returns({})

    GitHubRepositoryLabelActiveCheck
      .expects(:run)
      .returns({
                 url: 'https://github.com/up-for-grabs/up-for-grabs.net/labels/up-for-grabs'
               })

    message = PullRequestValidator.validate(dir, files)

    assert_markdown 'one-file', message
  end

  def test_one_file_warn_when_wrong_extension
    dir = get_test_directory('wrong-extension')
    files = get_files_in_directory('wrong-extension')

    message = PullRequestValidator.validate(dir, files)

    assert_markdown 'wrong-extension', message
  end

  def test_one_file_warn_when_no_extension
    dir = get_test_directory('missing-extension')
    files = get_files_in_directory('missing-extension')

    message = PullRequestValidator.validate(dir, files)

    assert_markdown 'missing-extension', message
  end

  def test_one_file_warn_when_schema_validation_failed
    dir = get_test_directory('schema-validation')
    files = get_files_in_directory('schema-validation')

    message = PullRequestValidator.validate(dir, files)

    assert_markdown 'schema-validation', message
  end

  def test_one_file_warn_when_tags_need_rename
    dir = get_test_directory('tags-validation')
    files = get_files_in_directory('tags-validation')

    message = PullRequestValidator.validate(dir, files)

    assert_markdown 'tags-validation', message
  end

  def test_one_file_warn_when_github_project_archived
    dir = get_test_directory('github-repository-archived')
    files = get_files_in_directory('github-repository-archived')

    # stub these calls that depend on the GitHub API
    archived = { reason: 'archived' }

    GitHubRepositoryActiveCheck
      .expects(:run)
      .returns(archived)

    message = PullRequestValidator.validate(dir, files)

    assert_markdown 'github-repository-archived', message
  end

  def test_one_file_changed_with_no_previous_message_includes_preamble
    skip 'TODO'
  end

  def test_one_file_changed_with_previous_message_omits_preamble
    skip 'TODO'
  end

  def test_two_files_with_no_problems_lists_both_files
    skip 'TODO'
  end

  def test_three_files_with_no_problems_lists_summary
    skip 'TODO'
  end

  def test_one_file_with_error_out_of_three_only_lists_problem_file
    skip 'TODO'
  end

  def test_twenty_files_without_error_lists_summary
    skip 'TODO'
  end

  def assert_markdown(name, output)
    parent = File.dirname(__dir__)
    expected = File.read("#{parent}/fixtures/pull_request/#{name}-result.md")
    assert_equal output.chomp, expected.chomp
  end

  def get_test_directory(name)
    parent = File.dirname(__dir__)
    Pathname.new("#{parent}/fixtures/pull_request/#{name}")
  end

  def get_files_in_directory(name)
    parent = File.dirname(__dir__)
    root = "#{parent}/fixtures/pull_request/#{name}"
    Dir.chdir(root) { Dir.glob('**/*').select { |path| File.file?(path) } }
  end
end
