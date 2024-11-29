# frozen_string_literal: true

# Represents the checks performed on a project to ensure it can be parsed
# and used as site data in Jekyll
class SchemaValidator
  def self.validate(project, schemer = nil)
    errors = []

    begin
      yaml = project.read_yaml
    rescue Psych::SyntaxError => e
      errors << "Unable to parse the contents of file - Line: #{e.line}, Offset: #{e.offset}, Problem: #{e.problem}"
    rescue StandardError => e
      errors << "Unknown exception for file: #{e}"
    end

    # don't continue if there was a problem parsing the file
    return errors if errors.any?

    if schemer.nil?
      library_root = File.dirname(__dir__, 2)
      schema = Pathname.new("#{library_root}/schema.json")
      schemer = JSONSchemer.schema(schema)
    end

    valid = schemer.valid?(yaml)
    unless valid
      raw_errors = schemer.validate(yaml).to_a
      formatted_messages = raw_errors.map { |err| format_error err }
      errors.concat(formatted_messages)
    end

    errors
  end

  def self.format_error(err)
    field = err.fetch('data_pointer')
    value = err.fetch('data')
    type = err.fetch('type')

    if field.start_with?('/tags/')
      "Tag '#{value}' contains invalid characters. Allowed characters: a-z, 0-9, +, #, . or -. Spaces are not allowed."
    elsif field.start_with?('/site') || field.start_with?('/upforgrabs/link')
      "Field '#{field}' expects a URL but instead found '#{value}'. Please check and update this value."
    elsif field.start_with?('/stats/last-updated')
      "Field '#{field}' expects date-time string but instead found '#{value}'. Please check and update this value."
    elsif field.start_with?('/stats/issue-count')
      "Field '#{field}' expects a non-negative integer but instead found '#{value}'. Please check and update this value."
    elsif type == 'required'
      details = err.fetch('details')
      keys = details['missing_keys']
      "Required fields are missing from file: #{keys.join(', ')}. Please check the example on the README and add these values."
    elsif field.start_with?('/tags')
      "Field 'tags' needs to be an array of elements. Check the file and try again."
    else
      "Field '#{field}' with value '#{value}' failed to satisfy the rule '#{type}'. Check the value and try again."
    end
  end

  private_class_method :format_error
end
