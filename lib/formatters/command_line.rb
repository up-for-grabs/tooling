module CommandLineFormatter
  def self.output(result)

    projects = result[:projects]

    unless projects.any? { |key,value| value[:errors].any? }
      puts "#{projects.count} files processed - no errors found!"
      return
    end

    projects_with_errors = projects.select { |key,value| value[:errors].any? }

    projects_with_errors.each do |key, value|
      puts "  - #{key}:"
      value[:errors].each { |error| puts "    - #{error}" }
    end

    puts "TODO: things"
  end
end

