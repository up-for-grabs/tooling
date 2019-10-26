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

  def github_project?
    github_owner_name_pair != nil
  end

  def github_owner_name_pair
    @github_owner_name_pair ||= find_github_owner_repo_pair
  end

  private

  def valid_url?(url)
    uri = URI.parse(url)
    uri.is_a?(URI::HTTP) || uri.is_a?(URI::HTTPS)
  rescue URI::InvalidURIError
    false
  end

  def find_github_owner_repo_pair
    yaml = read_yaml
    url = yaml['upforgrabs']['link']

    return nil unless valid_url?(url)

    uri = URI.parse(url)

    return nil unless uri.host.casecmp('github.com').zero?

    # path semgent in Ruby looks like /{owner}/repo so we drop the
    # first array value (which should be an empty string) and then
    # combine the next two elements
    path_segments = uri.path.split('/')

    # this likely means the URL points to a filtered search URL
    return nil if path_segments.length < 3

    values = path_segments.drop(1).take(2)

    # points to a project board for the organization
    return nil if values[0].casecmp('orgs').zero?

    values.join('/')
  end
end
