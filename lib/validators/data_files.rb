# frozen_string_literal: true

require_relative 'project'

# Validate the data files
class DataFilesValidator
  def self.validate(root, schemer)
    projects = Dir["#{root}/_data/projects/*.yml"].map do |f|
      relative_path = Pathname.new(f).relative_path_from(root).to_s
      Project.new(relative_path, f)
    end

    projects_with_errors = []

    projects.each do |p|
      validation_errors = ProjectValidator.validate(p, schemer)
      projects_with_errors << [p.relative_path, validation_errors] unless validation_errors.empty?
    end

    # if projects_with_errors.any?
    #   puts "#{projects_with_errors.count} errors found processing projects:"
    #   projects_with_errors.each do |project, errors|
    #     puts " - #{project.relative_path}:"
    #     errors.each { |error| puts "    - #{error}" }
    #   end
    # else
    #   puts "#{projects_without_issues.count} files processed - no errors found!"
    # end

    {
      count: projects.count,
      errors: projects_with_errors
    }
  end
end
