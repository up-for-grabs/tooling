# frozen_string_literal: true

# This class validates the repository state from the command line, and performs
# several checks during this process:
#
#  - schema validation for all current projects
#  - tag validation
#  - directory structure validation
#
class CommandLineValidator
  def self.validate(root, schemer = nil)
    projects = Dir["#{root}/_data/projects/*.yml"].map do |f|
      relative_path = Pathname.new(f).relative_path_from(root).to_s
      Project.new(relative_path, f)
    end

    if schemer.nil?
      library_root = File.dirname(__dir__, 2)
      schema = Pathname.new("#{library_root}/schema.json")
      schemer = JSONSchemer.schema(schema)
    end

    results = {}

    success = true

    projects.each do |p|
      errors = SchemaValidator.validate(p, schemer)
      errors.concat TagsValidator.validate(p)

      success = false if errors.any?

      results.store(p.relative_path, { errors: })
    end

    directory_result = DirectoryValidator.validate(root)

    result = {
      projects: results
    }.merge(directory_result)

    success = false if directory_result[:project_files_at_root].any?
    success = false if directory_result[:invalid_data_files].any?

    result[:success] = success

    result
  end
end
