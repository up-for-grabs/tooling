# frozen_string_literal: true

# This module contains the formatter for use when consuming the analysis from
# the command line, and will emit results to the terminal using `puts`
module CommandLineFormatter
  def self.output(result)
    directory_problems = directory_problem_lines(result)

    if directory_problems.any?
      directory_problems.each { |line| puts line }
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
  end

  # The lines describing the first problem found in the directory layout, or
  # none when it is fine.
  def self.directory_problem_lines(result)
    [
      root_file_lines(result[:project_files_at_root] || []),
      invalid_data_file_lines(result[:invalid_data_files] || []),
      case_conflict_lines(result[:case_conflicting_files] || [])
    ].find(&:any?) || []
  end

  def self.root_file_lines(files)
    return [] if files.empty?

    ["#{files.length} files found in root which look like project files:",
     *files.map { |f| "  - #{f}" },
     'Move these inside _data/projects/ to ensure they are listed on the site']
  end

  def self.invalid_data_file_lines(files)
    return [] if files.empty?

    ["#{files.length} files found in projects directory which are not YAML files:",
     *files.map { |f| "  - #{f}" },
     'Remove these from the repository as they will not be used by the site']
  end

  def self.case_conflict_lines(groups)
    return [] if groups.empty?

    ["#{groups.flatten.length} project files have names that differ only by case:",
     *groups.map { |group| "  - #{group.join(', ')}" },
     'Rename or remove files so each name is unique ignoring case, as Windows and macOS checkouts cannot hold them all']
  end
end
