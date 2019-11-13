# frozen_string_literal: true

require 'safe_yaml/load'

require 'find'
require 'json_schemer'

require 'graphql/client'
require 'graphql/client/http'

require 'models/project'

require 'validators/data_files'
require 'validators/directory'
# TODO: deprecate this once the main project is no longer using it
require 'validators/project'
require 'validators/schema'
require 'validators/tags'

require 'queries/github_repository_active_check'
require 'queries/github_repository_label_active_check'
