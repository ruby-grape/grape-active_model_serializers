source 'https://rubygems.org'

gemspec

case version = ENV['GRAPE_VERSION'] || '~> 3.0.0'
when 'HEAD'
  gem 'grape', github: 'intridea/grape'
else
  gem 'grape', version
end

group :test do
  gem 'rack-test'
  gem 'ruby-grape-danger', '~> 0.2.0', require: false
  gem 'sequel', '~> 5.91', require: false
  gem 'sqlite3'
end

group :development, :test do
  gem 'guard-rspec'
  gem 'listen', '~> 3.9.0'
  gem 'rake'
  gem 'rspec'
  gem 'rubocop', '1.75.7'
end
