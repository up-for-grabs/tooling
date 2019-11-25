# frozen_string_literal: true

# Represents the checks performed on the tags specified in a project satisfy the
# requirements for what we are curating
class TagsValidator
  def self.validate(project)
    errors = []

    begin
      yaml = project.read_yaml
    rescue Psych::SyntaxError => e
      errors << "Unable to parse the contents of file - Line: #{e.line}, Offset: #{e.offset}, Problem: #{e.problem}"
    rescue StandardError => e
      errors << "Unknown exception for file: #{e}"
    end

    # don't continue if there was a problem parsing
    return errors if errors.any?

    validate_tags(yaml)
  end

  # preference is a map of [bad tag]: [preferred tag]
  PREFERENCES = {
    'algorithms' => 'algorithm',
    'appletv' => 'apple-tv',
    'asp-net' => 'asp.net',
    'aspnet' => 'asp.net',
    'aspnetmvc' => 'aspnet-mvc',
    'aspnetcore' => 'aspnet-core',
    'asp-net-core' => 'aspnet-core',
    'assembler' => 'assembly',
    'builds' => 'build',
    'collaborate' => 'collaboration',
    'coding' => 'code',
    'colour' => 'color',
    'commandline' => 'command-line',
    'csharp' => 'c#',
    'docs' => 'documentation',
    'dotnet' => '.net',
    'dotnet-core' => '.net core',
    'encrypt' => 'encryption',
    'fsharp' => 'f#',
    'games' => 'game',
    'gatsby' => 'gatsbyjs',
    'golang' => 'go',
    'js' => 'javascript',
    'library' => 'libraries',
    'linters' => 'linter',
    'node' => 'node.js',
    'nodejs' => 'node.js',
    'nuget.exe' => 'nuget',
    'parser' => 'parsing',
    'react' => 'reactjs'
  }.freeze

  def self.validate_preferred_tags(tags)
    errors = []

    tags.each do |tag|
      preferred_tag = PREFERENCES[tag]

      errors << "Rename tag '#{tag}' to be'#{preferred_tag}'" if preferred_tag
    end

    errors
  end

  def self.validate_tags(yaml)
    errors = []

    tags = yaml['tags']

    return ['No tags defined for file'] if tags.nil? || tags.empty?

    unless tags.is_a?(Array)
      return ["Expected array for tags but found value '#{tags}'"]
    end

    errors.concat(validate_preferred_tags(tags))

    dups = tags.group_by { |t| t }.keep_if { |_, t| t.length > 1 }

    errors << "Duplicate tags found: #{dups.keys.join ', '}" if dups.any?

    errors
  end

  private_class_method :validate_preferred_tags, :validate_tags
end
