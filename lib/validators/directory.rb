# frozen_string_literal: true

# Check the projects directory for anything invalid
class DirectoryValidator
  VALID_YAML_FILES = ['_config.yml', 'docker-compose.yml', '.rubocop.yml'].freeze

  def self.validate(root)
    Kernel.warn 'DirectoryValidator.validate is obsolete, and should be replaced with CommandLineValidator.validate'
    invalid_data_files = []

    projects_dir = File.join(root, '_data', 'projects')

    Find.find(projects_dir) do |path|
      next unless FileTest.file?(path)

      relative_path = Pathname.new(path).relative_path_from(root).to_s

      invalid_data_files << relative_path if File.extname(path) != '.yml'
    end

    project_files_at_root = []

    Find.find(root) do |path|
      next unless FileTest.file?(path)

      dirname = File.dirname(path)
      normalized_dirname = Pathname.new(dirname)

      next unless normalized_dirname == root

      basename = File.basename(path)
      next if VALID_YAML_FILES.include?(basename)

      project_files_at_root << basename if File.extname(path) == '.yml'
    end

    {
      project_files_at_root: project_files_at_root,
      invalid_data_files: invalid_data_files
    }
  end
end
