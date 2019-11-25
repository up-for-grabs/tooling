# frozen_string_literal: true

require_relative '../test_helper'

class CommandLineFormatterTests < Minitest::Test
  def test_command_line_lists_failures
    result = {
      # TODO: what do we put in here?
      :projects => {
        '_data/projects/first.yml' => {
          :valid => true
        },
        '_data/projects/second.yml' => {
          :valid => false,
          :errors => [
            'unable '
          ]
        }
      }
     }

    out, err = capture_io do
      CommandLineFormatter.output(result)
    end

    assert_match %r%something went wrong?%, out
  end
end
