source 'https://rubygems.org'

gemspec

case version = ENV['GRAPE_VERSION'] || '>= 2.3.0'
when 'HEAD'
  gem 'grape', github: 'ruby-grape/grape'
else
  gem 'grape', version
end

group :test do
  gem 'rack-test'
  gem 'sequel', '~> 5.91', require: false
  gem 'simplecov', require: false
  gem 'simplecov-lcov', require: false
  gem 'sqlite3'
end

group :development, :test do
  gem 'guard-rspec'
  gem 'listen', '~> 3.9.0'
  gem 'rake'
  gem 'rspec'
  gem 'rubocop', '~> 1.92.0', require: false
end

group :danger do
  gem 'danger-pr-comment', '~> 0.1.0', require: false
  gem 'ruby-grape-danger', '~> 0.3.0', require: false
end
