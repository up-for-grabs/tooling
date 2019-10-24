# frozen_string_literal: true

# Contains the common fields of a project as stored in the data files of the site
class Project
  attr_accessor :full_path, :relative_path

  def initialize(relative_path, full_path)
    @relative_path = relative_path
    @full_path = full_path
  end

  def format_yaml
    write_yaml(read_yaml)
  end

  def read_yaml
    YAML.safe_load(File.read(@full_path))
  end

  def write_yaml(obj)
    File.open(@full_path, 'w') { |f| f.write obj.to_yaml(line_width: 100) }
  end
end
