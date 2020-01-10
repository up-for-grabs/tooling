# frozen_string_literal: true

require_relative '../test_helper'

class CommandLineValidatorTests < Minitest::Test
  def test_lists_projects_processed
    path = get_data_files_directory('valid_project_files')

    result = CommandLineValidator.validate(path)

    projects = result[:projects]

    assert projects['_data/projects/julia.yml'][:errors].empty?
    assert projects['_data/projects/timegrid.yml'][:errors].empty?
    assert projects['_data/projects/up-for-grabs.net.yml'][:errors].empty?
  end

  def test_incorrect_files_found
    path = get_directory('incorrect_files_found')

    result = CommandLineValidator.validate(path)

    invalid_data_files = result[:invalid_data_files]
    project_files_at_root = result[:project_files_at_root]

    assert_equal ['_data/projects/thing.json'], invalid_data_files
    assert_equal ['lost_project_file.yml'], project_files_at_root
  end

  def get_directory(name)
    parent = File.dirname(__dir__)
    Pathname.new("#{parent}/fixtures/directory/#{name}")
  end

  def get_data_files_directory(name)
    parent = File.dirname(__dir__)
    Pathname.new("#{parent}/fixtures/data_files/#{name}")
  end
end
