# frozen_string_literal: true

require_relative '../test_helper'

class DirectoryValidatorTests < Minitest::Test
  def test_incorrect_files_found
    path = get_directory('incorrect_files_found')

    result = DirectoryValidator.validate(path)

    assert_equal ['_data/projects/thing.json'], result[:invalid_data_files]
    assert_equal ['lost_project_file.yml'], result[:project_files_at_root]
  end

  def get_directory(name)
    parent = File.dirname(__dir__)
    Pathname.new("#{parent}/fixtures/directory/#{name}")
  end
end
