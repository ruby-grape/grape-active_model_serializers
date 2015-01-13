# -*- encoding: utf-8 -*-
require File.expand_path('../lib/grape-active_model_serializers/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ['Jonathan Richard Henry Evans']
  gem.email         = ['contact@jrhe.co.uk']
  gem.summary       = 'Use active_model_serializer in grape'
  gem.description   = 'Provides a Formatter for the Grape API DSL to emit objects serialized with active_model_serializers.'
  gem.homepage      = 'https://github.com/jrhe/grape-active_model_serializers'

  gem.executables   = `git ls-files -- bin/*`.split("\n").map { |f| File.basename(f) }
  gem.files         = `git ls-files`.split("\n")
  gem.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  gem.name          = 'grape-active_model_serializers'
  gem.require_paths = ['lib']
  gem.version       = Grape::ActiveModelSerializers::VERSION
  gem.licenses      = ['MIT']

  gem.add_dependency 'grape'
  gem.add_dependency 'active_model_serializers', '>= 0.9.0'

  gem.add_development_dependency 'rspec'
  gem.add_development_dependency 'rack-test'
  gem.add_development_dependency 'rake'
  gem.add_development_dependency 'guard-rspec'
  gem.add_development_dependency 'rubocop', '0.28.0'
end
