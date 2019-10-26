# frozen_string_literal: true

require_relative '../test_helper'

class DataFilesValidatorTests < Minitest::Test
  def test_valid_directory
    schemer = setup_schemer
    path = get_directory('valid_project_files')

    result = DataFilesValidator.validate(path, schemer)

    assert_equal 3, result[:count]
    assert result[:errors].empty?
  end

  def setup_schemer
    root = File.dirname(File.dirname(__dir__))
    schema = Pathname.new("#{root}/schema.json")
    JSONSchemer.schema(schema)
  end

  def get_directory(name)
    parent = File.dirname(__dir__)
    Pathname.new("#{parent}/fixtures/data_files/#{name}")
  end
end
