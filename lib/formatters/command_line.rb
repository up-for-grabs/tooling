module CommandLineFormatter
  def self.output(result)

    orphaned_project_files = result[:orphaned_project_files] || []

    if orphaned_project_files.any?
      puts "#{orphaned_project_files.length} files found in root which look like project files:"
      orphaned_project_files.each { |f| puts "  - #{f}" }
      puts 'Move these inside _data/projects/ to ensure they are listed on the site'
      return
    end

    projects = result[:projects] || {}

    unless projects.any? { |key,value| value[:errors].any? }
      puts "#{projects.count} files processed - no errors found!"
      return
    end

    projects_with_errors = projects.select { |key,value| value[:errors].any? }

    projects_with_errors.each do |key, value|
      puts "  - #{key}:"
      value[:errors].each { |error| puts "    - #{error}" }
    end
  end
end

