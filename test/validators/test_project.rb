# frozen_string_literal: true

require 'minitest/autorun'
require './lib/up_for_grabs_tooling'

class ProjectValidatorTests < Minitest::Test
  def test_valid_file_returns_no_errors
    schemer = setup_schemer
    project = get_project('valid_project_file.yml')

    result = ProjectValidator.validate(project, schemer)

    assert result.empty?
  end

  def test_parsing_error
    schemer = setup_schemer
    project = get_project('error_parsing.yml')

    result = ProjectValidator.validate(project, schemer)

    assert_equal result[0], 'Unable to parse the contents of file - Line: 1, Offset: 0, Problem: found unknown escape character'
  end

  def test_upper_case_tag_error
    schemer = setup_schemer
    project = get_project('error_upper_case_tag.yml')

    result = ProjectValidator.validate(project, schemer)

    assert_equal result[0], "Tag 'Web' contains invalid characters. Allowed characters: a-z, 0-9, +, #, . or -"
  end

  def test_site_link_url_error
    schemer = setup_schemer
    project = get_project('error_site_link_url.yml')

    result = ProjectValidator.validate(project, schemer)

    assert_equal result[0], "Field '/site' expects a URL but instead found 'foo'. Please check and update this value."
  end

  def test_upforgrabs_link_url_error
    schemer = setup_schemer
    project = get_project('error_upforgrabs_link_url.yml')

    result = ProjectValidator.validate(project, schemer)

    assert_equal result[0],  "Field '/upforgrabs/link' expects a URL but instead found 'not-a-url'. Please check and update this value."
  end

  def setup_schemer
    root = File.dirname(File.dirname(__dir__))
    schema = Pathname.new("#{root}/schema.json")
    JSONSchemer.schema(schema)
  end

  def get_project(name)
    parent = File.dirname(__dir__)
    full_path = Pathname.new("#{parent}/fixtures/projects/#{name}")
    Project.new(name, full_path.to_s)
  end
end
