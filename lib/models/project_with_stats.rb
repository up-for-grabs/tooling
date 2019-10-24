# frozen_string_literal: true

require_relative 'project.rb'

# Represents the checks performed on a project to ensure it can be parsed
# and used as site data in Jekyll
class ProjectWithStats < Project
  def initialize(relative_path, full_path, apply_changes = false)
    super(relative_path, full_path)

    @apply_changes = apply_changes
  end

  def update(stats)
    obj = read_yaml
    obj.store('stats', 'issue-count' => stats[:count], 'last-updated' => stats[:updated_at])
    write_yaml(obj)
  end
end
