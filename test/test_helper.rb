# frozen_string_literal: true

require 'simplecov'
SimpleCov.start do
  add_filter '/test/'
end

require 'minitest/autorun'
require 'mocha/minitest'

require './lib/up_for_grabs_tooling'
