# frozen_string_literal: true

require_relative '../test_helper'

class CommandLineFormatterTests < Minitest::Test
  def test_command_line_lists_failing_files
    result = {
      projects: {
        '_data/projects/first.yml': {
          errors: []
        },
        '_data/projects/second.yml': {
          errors: [
            'No tags defined for file',
            "Field 'something' expects a URL but instead found 'foo'"
          ]
        }
      }
    }

    out, err = capture_io do
      CommandLineFormatter.output(result)
    end

    assert_match %r%  - _data/projects/second.yml%, out
    assert_match %r%    - No tags defined for file%, out
    assert_match %r%    - Field 'something' expects a URL but instead found 'foo'%, out
  end

  def test_command_line_displays_success
    result = {
      projects: {
        '_data/projects/first.yml': {
          errors: []
        },
        '_data/projects/second.yml': {
          errors: []
        }
      }
    }

    out, err = capture_io do
      CommandLineFormatter.output(result)
    end

    assert_match %r%2 files processed - no errors found!%, out
  end


  def test_command_line_lists_orphaned_files
    result = {
      orphaned_project_files: [
        'first.yml',
        'second.yml'
      ]
    }

    out, err = capture_io do
      CommandLineFormatter.output(result)
    end

    assert_match %r%2 files found in root which look like project files%, out
    assert_match %r%  - first.yml%, out
    assert_match %r%  - second.yml%, out
    assert_match %r%Move these inside _data/projects/ to ensure they are listed on the site%, out
  end
end
