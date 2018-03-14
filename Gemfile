source 'https://rubygems.org'

gemspec

case version = ENV['GRAPE_VERSION'] || '~> 1.0.0'
when 'HEAD'
  gem 'grape', github: 'intridea/grape'
else
  gem 'grape', version
end

group :test do
  gem 'ruby-grape-danger', '~> 0.1.0', require: false
  gem 'sequel', '~> 4.37', require: false
  gem 'sqlite3'
end
