# frozen_string_literal: true

class SchemaValidatorTests < Minitest::Test
  def test_valid_file_returns_no_errors
    project = create_project('valid_project_file.yml')

    result = SchemaValidator.validate(project)

    assert_empty result
  end

  def test_valid_file_with_stats_returns_no_errors
    project = create_project('valid_project_with_stats.yml')

    result = SchemaValidator.validate(project)

    assert_empty result
  end

  def test_valid_file_with_no_open_issues_returns_no_errors
    project = create_project('valid_project_with_no_open_issues.yml')

    result = SchemaValidator.validate(project)

    assert_empty result
  end

  def test_parsing_error
    project = create_project('error_parsing.yml')

    result = SchemaValidator.validate(project)

    assert_equal result[0], 'Unable to parse the contents of file - Line: 1, Offset: 0, Problem: found unknown escape character'
  end

  def test_missing_file_error
    project = create_project('file_not_found.yml')

    result = SchemaValidator.validate(project)

    assert result[0].start_with?('Unknown exception for file: No such file or directory')
  end

  def test_required_fields_error
    project = create_project('error_required_fields.yml')

    result = SchemaValidator.validate(project)

    assert_equal result[0], 'Required fields are missing from file: name, link. Please check the example on the README and add these values.'
  end

  def test_upper_case_tag_error
    project = create_project('error_upper_case_tag.yml')

    result = SchemaValidator.validate(project)

    assert_equal result[0], "Tag 'Web' contains invalid characters. Allowed characters: a-z, 0-9, +, #, . or -"
  end

  def test_site_link_url_error
    project = create_project('error_site_link_url.yml')

    result = SchemaValidator.validate(project)

    assert_equal result[0], "Field '/site' expects a URL but instead found 'foo'. Please check and update this value."
  end

  def test_upforgrabs_link_url_error
    project = create_project('error_upforgrabs_link_url.yml')

    result = SchemaValidator.validate(project)

    assert_equal result[0], "Field '/upforgrabs/link' expects a URL but instead found 'not-a-url'. Please check and update this value."
  end

  def test_stats_negative_issue_count_error
    project = create_project('error_stats_negative_issue_count.yml')

    result = SchemaValidator.validate(project)

    assert_equal result[0], "Field '/stats/issue-count' expects a non-negative integer but instead found '-1'. Please check and update this value."
  end

  def test_stats_invalid_last_updated_error
    project = create_project('error_stats_invalid_last_updated.yml')

    result = SchemaValidator.validate(project)

    assert_equal result[0], "Field '/stats/last-updated' expects date-time string but instead found '18 December 2019'. Please check and update this value."
  end

  def test_no_tags_error
    project = create_project('error_no_tags.yml')

    result = SchemaValidator.validate(project)

    assert_equal result[0], 'Required fields are missing from file: tags. Please check the example on the README and add these values.'
  end

  def test_empty_tags_error
    project = create_project('error_empty_tags.yml')

    result = SchemaValidator.validate(project)

    assert_equal result[0], "Field 'tags' needs to be an array of elements. Check the file and try again."
  end

  def test_tags_as_string_error
    project = create_project('error_tags_as_string.yml')

    result = SchemaValidator.validate(project)

    assert_equal result[0], "Field 'tags' needs to be an array of elements. Check the file and try again."
  end

  def create_project(name)
    parent = File.dirname(__dir__)
    full_path = Pathname.new("#{parent}/fixtures/projects/#{name}")
    Project.new(name, full_path.to_s)
  end
end
