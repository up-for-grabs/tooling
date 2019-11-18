# frozen_string_literal: true

require_relative '../test_helper'

class TagsValidatorTests < Minitest::Test
  def test_duplicate_tag_error
    project = create_project('error_duplicate_tags.yml')

    result = TagsValidator.validate(project)

    assert_equal result[0], 'Duplicate tags found: javascript'
  end

  def test_recommended_tag_error
    project = create_project('error_recommended_tag.yml')

    result = TagsValidator.validate(project)

    assert_equal result[0], "Rename tag 'js' to be'javascript'"
  end

  def test_tags_as_string_error
    project = create_project('error_tags_as_string.yml')

    result = TagsValidator.validate(project)

    assert_equal result[0], "Expected array for tags but found value 'hello'"
  end

  def create_project(name)
    parent = File.dirname(__dir__)
    full_path = Pathname.new("#{parent}/fixtures/projects/#{name}")
    Project.new(name, full_path.to_s)
  end
end
