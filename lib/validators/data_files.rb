# frozen_string_literal: true

# Validate the data files
class DataFilesValidator
  def self.validate(root, schemer = nil)
    Kernel.warn "DataFilesValidator.validate is obsolete, and should be replaced with CommandLineValidator.validate that provides a superset of this functionality"

    projects = Dir["#{root}/_data/projects/*.yml"].map do |f|
      relative_path = Pathname.new(f).relative_path_from(root).to_s
      Project.new(relative_path, f)
    end

    projects_with_errors = {}

    if schemer.nil?
      root = File.dirname(File.dirname(__dir__))
      schema = Pathname.new("#{root}/schema.json")
      schemer = JSONSchemer.schema(schema)
    end

    projects.each do |p|
      validation_errors = SchemaValidator.validate(p, schemer)
      unless validation_errors.empty?
        projects_with_errors.store(p.relative_path, validation_errors)
        next
      end

      tag_errors = TagsValidator.validate(p)
      unless tag_errors.empty?
        projects_with_errors.store(p.relative_path, tag_errors)
      end
    end

    {
      count: projects.count,
      errors: projects_with_errors
    }
  end
end
