# frozen_string_literal: true

require_relative '../test_helper'

class DataFilesValidatorTests < Minitest::Test
  def test_valid_directory
    path = get_directory('valid_project_files')

    result = DataFilesValidator.validate(path)

    assert_equal 3, result[:count]
    assert result[:errors].empty?
  end

  def test_file_has_error
    path = get_directory('one_file_with_error')

    result = DataFilesValidator.validate(path)

    assert_equal 2, result[:count]
    assert_equal 1, result[:errors].length

    errors = result[:errors]['_data/projects/error_site_link_url.yml']
    assert_equal 1, errors.length
    assert_equal errors[0], "Field '/site' expects a URL but instead found 'foo'. Please check and update this value."
  end

  def get_directory(name)
    parent = File.dirname(__dir__)
    Pathname.new("#{parent}/fixtures/data_files/#{name}")
  end
end
