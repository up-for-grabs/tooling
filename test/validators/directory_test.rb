# frozen_string_literal: true

require_relative '../test_helper'
require 'fileutils'
require 'tmpdir'

class DirectoryValidatorTests < Minitest::Test
  def test_case_conflicts_groups_names_that_differ_only_by_case
    paths = [
      '_data/projects/Foo-Bar.yml',
      '_data/projects/other.yml',
      '_data/projects/foo-bar.yml',
      '_data/projects/FOO-BAR.yml'
    ]

    assert_equal [['_data/projects/FOO-BAR.yml', '_data/projects/Foo-Bar.yml', '_data/projects/foo-bar.yml']],
                 DirectoryValidator.case_conflicts(paths)
  end

  def test_case_conflicts_is_empty_for_unique_names
    assert_empty DirectoryValidator.case_conflicts(['_data/projects/a.yml', '_data/projects/b.yml'])
  end

  def test_valid_fixtures_have_no_case_conflicts
    result = DirectoryValidator.validate(get_data_files_directory('valid_project_files'))

    assert_empty result[:case_conflicting_files]
  end

  def test_reports_project_files_that_differ_only_by_case
    Dir.mktmpdir do |root|
      projects = File.join(root, '_data', 'projects')
      FileUtils.mkdir_p(projects)
      File.write(File.join(projects, 'crop-system.yml'), "name: lower\n")
      File.write(File.join(projects, 'Crop-System.yml'), "name: upper\n")

      # A case-insensitive filesystem keeps only one of the two files
      skip 'filesystem is case-insensitive' if Dir.children(projects).length < 2

      result = DirectoryValidator.validate(Pathname.new(root))

      assert_equal [['_data/projects/Crop-System.yml', '_data/projects/crop-system.yml']],
                   result[:case_conflicting_files]
    end
  end

  def get_data_files_directory(name)
    parent = File.dirname(__dir__)
    Pathname.new("#{parent}/fixtures/data_files/#{name}")
  end
end
