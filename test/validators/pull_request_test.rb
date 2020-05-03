# frozen_string_literal: true

require_relative '../test_helper'

class PullRequestValidatorTests < Minitest::Test
  def test_one_file_is_good_to_merge
    dir = get_test_directory('one-file')
    files = get_files_in_directory('one-file')

    # stub these calls that depend on the GitHub API
    PullRequestValidator
      .expects(:repository_check)
      .returns(nil)

    PullRequestValidator
      .expects(:label_check)
      .returns(nil)

    message = PullRequestValidator.validate(dir, files)

    assert_match '#### `_data/projects/project.yml` :white_check_mark: ', message
    assert_match 'No problems found, everything should be good to merge!', message
  end

  def test_one_file_warn_when_wrong_extension
    dir = get_test_directory('wrong-extension')
    files = get_files_in_directory('wrong-extension')

    message = PullRequestValidator.validate(dir, files)

    assert_match '#### Unexpected files found in project directory', message
    assert_match ' - `_data/projects/project.yaml`', message
    assert_match 'All files under `_data/projects/` must end with `.yml` to be listed on the site', message
  end

  def test_one_file_warn_when_no_extension
    dir = get_test_directory('missing-extension')
    files = get_files_in_directory('missing-extension')

    message = PullRequestValidator.validate(dir, files)

    assert_match '#### Unexpected files found in project directory', message
    assert_match ' - `_data/projects/project`', message
    assert_match 'All files under `_data/projects/` must end with `.yml` to be listed on the site', message
  end

  # def test_one_file_warn_when_schema_validation_failed
  #   refute true
  # end

  # def test_one_file_warn_when_tags_need_rename
  #   refute true
  # end

  # def test_one_file_changed_with_no_previous_message_includes_preamble
  #   refute true
  # end

  # def test_one_file_changed_with_previous_message_omits_preamble
  #   refute true
  # end

  # def test_two_files_with_no_problems_lists_both_files
  #   refute true
  # end

  # def test_three_files_with_no_problems_lists_summary
  #   refute true
  # end

  # def test_one_file_with_error_out_of_three_only_lists_problem_file
  #   refute true
  # end

  # def test_twenty_files_without_error_lists_summary
  #   refute true
  # end

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
