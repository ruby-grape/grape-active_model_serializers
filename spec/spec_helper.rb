$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
$LOAD_PATH.unshift(File.dirname(__FILE__))

require 'bundler'
Bundler.setup :default, :test

require 'active_support/core_ext/hash/conversions'
require 'active_model'
require "active_model_serializers"
require "active_support/json"
require 'grape/active_model_serializers'
require 'rspec'
require 'rack/test'
require "pry"
require 'nulldb_rspec'

include NullDB::RSpec::NullifiedDatabase

NullDB.configure do |ndb|
  def ndb.project_root
    File.dirname(__FILE__)
  end
end

RSpec.configure do |config|
  config.include Rack::Test::Methods
end

Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each {|f| require f}
