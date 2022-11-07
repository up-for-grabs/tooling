Gem::Specification.new do |s|
  s.name        = 'up_for_grabs_tooling'
  s.version     = '0.1.0'
  s.licenses    = ['MIT']
  s.summary     = "Tooling for Up-For-Grabs infrastructure"
  s.description = "This gem is used to simplify the heavy-lifting that infrastructure scripts for Up-For-Grabs uses. As it's very specific to the Up-For-Grabs project, you don't need to use this yourself."
  s.authors     = ["Brendan Forster"]
  s.email       = 'github@brendanforster.com'
  s.files       = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test)/})
  end
  s.homepage    = 'https://github.com/up-for-grabs/up-for-grabs-gem'
  s.metadata    = { "source_code_uri" => "https://github.com/up-for-grabs/up-for-grabs-gem" }

  s.add_runtime_dependency 'safe_yaml', '~> 1.0'
  s.add_runtime_dependency 'octokit', '>= 5.6', '< 7.0'
  s.add_runtime_dependency 'graphql-client', '~> 0.18'
  s.add_runtime_dependency 'json_schemer', '~> 0.2'
end
