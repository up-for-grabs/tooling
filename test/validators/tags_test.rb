# frozen_string_literal: true

class TagsValidatorTests < Minitest::Test
  def test_duplicate_tag_error
    project = create_project('error_duplicate_tags.yml')

    result = TagsValidator.validate(project)

    assert_equal('Duplicate tags found: javascript', result[0])
  end

  def test_recommended_tag_error
    project = create_project('error_recommended_tag.yml')

    result = TagsValidator.validate(project)

    assert_equal("Rename tag 'js' to be 'javascript'", result[0])
  end

  def test_tags_as_string_error
    project = create_project('error_tags_as_string.yml')

    result = TagsValidator.validate(project)

    assert_equal("Expected array for tags but found value 'hello'", result[0])
  end

  def create_project(name)
    parent = File.dirname(__dir__)
    full_path = Pathname.new("#{parent}/fixtures/projects/#{name}")
    Project.new(name, full_path.to_s)
  end
end
