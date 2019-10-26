# frozen_string_literal: true

require 'fileutils'

require_relative '../test_helper'

class FormatYamlFilesTests < Minitest::Test
  def test_fix_indenting
    expected_text = get_expected_text('fix-indenting')
    @temp_file = copy_file_to_temp('fix-indenting')
    project = create_project(@temp_file)

    project.format_yaml

    actual_text = File.read(@temp_file.path)

    assert_equal expected_text, actual_text
  end

  def test_add_stats
    expected_text = get_expected_text('add-stats')
    @temp_file = copy_file_to_temp('add-stats')
    project = create_project(@temp_file)

    project.update(count: 1, updated_at: '2019-10-25T10:39:05Z')

    actual_text = File.read(@temp_file.path)

    assert_equal expected_text, actual_text
  end

  def teardown
    return unless @temp_file

    @temp_file.close
    @temp_file.unlink
  end

  def get_expected_text(name)
    parent = File.dirname(__dir__)
    after_file = Pathname.new("#{parent}/fixtures/formatting/#{name}/after.yml")
    File.read(after_file)
  end

  def copy_file_to_temp(name)
    temp_file = Tempfile.new(['test-formatting', '.yml'])
    parent = File.dirname(__dir__)
    before_file = Pathname.new("#{parent}/fixtures/formatting/#{name}/before.yml")
    FileUtils.copy_file(before_file, temp_file.path)
    temp_file
  end

  def create_project(temp_file)
    name = File.basename(temp_file.path)
    Project.new(name, temp_file.path)
  end
end
