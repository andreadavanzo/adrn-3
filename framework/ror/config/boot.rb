ENV["BUNDLE_GEMFILE"] ||= File.expand_path("../Gemfile", __dir__)

require "bundler/setup" # Set up gems listed in the Gemfile.
require "bootsnap/setup" # Speed up boot time by caching expensive operations.
ENV['RAILS_ENV'] ||= 'production'
ENV['RACK_ENV']  ||= 'production'
ENV['ROR_DATABASE_USERNAME'] ||= 'tester'
ENV['ROR_DATABASE_PASSWORD'] ||= 'tester'