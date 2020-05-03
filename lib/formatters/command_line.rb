# frozen_string_literal: true

# This module contains the formatter for use when consuming the analysis from
# the command line, and will emit results to the terminal using `puts`
module CommandLineFormatter
  def self.output(result)
    project_files_at_root = result[:project_files_at_root] || []

    if project_files_at_root.any?
      puts "#{project_files_at_root.length} files found in root which look like project files:"
      project_files_at_root.each { |f| puts "  - #{f}" }
      puts 'Move these inside _data/projects/ to ensure they are listed on the site'
      return
    end

    invalid_data_files = result[:invalid_data_files] || []

    if invalid_data_files.any?
      puts "#{invalid_data_files.length} files found in projects directory which are not YAML files:"
      invalid_data_files.each { |f| puts "  - #{f}" }
      puts 'Remove these from the repository as they will not be used by the site'
      return
    end

    projects = result[:projects] || {}

    unless projects.any? { |_key, value| value[:errors].any? }
      puts "#{projects.count} files processed - no errors found!"
      return
    end

    projects_with_errors = projects.select { |_key, value| value[:errors].any? }

    puts "#{projects_with_errors.count} files contain errors:"

    projects_with_errors.each do |key, value|
      puts "  - #{key}:"
      value[:errors].each { |error| puts "    - #{error}" }
    end

    exit(1)
  end
end
