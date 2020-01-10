# frozen_string_literal: true

require_relative '../test_helper'

class CommandLineFormatterTests < Minitest::Test
  def test_command_line_lists_failures
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
end
