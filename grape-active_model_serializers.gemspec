# -*- encoding: utf-8 -*-
require File.expand_path('../lib/grape-active_model_serializers/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Jonathan Richard Henry Evans"]
  gem.email         = ["contact@jrhe.co.uk"]
  gem.description   = %q{Use active_model_serializer in grape}
  gem.summary       = %q{Use active_model_serializer in grape}
  gem.homepage      = "https://github.com/jrhe/grape-rabl"

  gem.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  gem.files         = `git ls-files`.split("\n")
  gem.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  gem.name          = "grape-active_model_serializers"
  gem.require_paths = ["lib"]
  gem.version       = Grape::ActiveModelSerializers::VERSION

  gem.add_dependency "grape", "~> 0.3"
  gem.add_dependency "activerecord"
  gem.add_dependency "active_model_serializers"
  gem.add_dependency "tilt"
  gem.add_dependency "i18n"
end
