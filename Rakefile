#!/usr/bin/env rake
require 'bundler/gem_tasks'

require 'rspec/core'
require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new(:spec) do |spec|
  spec.rspec_opts = ['-fd -c']
  spec.pattern = FileList['spec/**/*_spec.rb']
end

require 'rubocop/rake_task'
RuboCop::RakeTask.new(:rubocop)

task default: [:rubocop, :spec]
