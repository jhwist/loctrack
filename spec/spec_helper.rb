require File.join(File.dirname(__FILE__), '..', 'loctrack.rb')

require 'sinatra'
require "mongoid"
require "rspec"

# setup test environment
set :environment, :test
set :run, false
set :raise_errors, true
set :logging, false

$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), "..", "lib"))

MODELS = File.join(File.dirname(__FILE__), "app/models")
SUPPORT = File.join(File.dirname(__FILE__), "support")
$LOAD_PATH.unshift(MODELS)
$LOAD_PATH.unshift(SUPPORT)


# These environment variables can be set if wanting to test against a database
# that is not on the local machine.
ENV["MONGOID_SPEC_HOST"] ||= "localhost"
ENV["MONGOID_SPEC_PORT"] ||= "27017"

# These are used when creating any connection in the test suite.
HOST = ENV["MONGOID_SPEC_HOST"]
PORT = ENV["MONGOID_SPEC_PORT"].to_i


# When testing locally we use the database named mongoid_test. However when
# tests are running in parallel on Travis we need to use different database
# names for each process running since we do not have transactions and want a
# clean slate before each spec run.
def database_id
  ENV["CI"] ? "mongoid_#{Process.pid}" : "mongoid_test"
end

# Can we connect to MongoHQ from this box?
def mongohq_connectable?
  ENV["MONGOHQ_REPL_PASS"].present?
end

# Set the database that the spec suite connects to.
Mongoid.configure do |config|
  config.databases=(database_id)
end

# Autoload every model for the test suite that sits in spec/app/models.
Dir[ File.join(MODELS, "*.rb") ].sort.each do |file|
  name = File.basename(file, ".rb")
  autoload name.camelize.to_sym, name
end

# Require everything in spec/support.
Dir[ File.join(SUPPORT, "*.rb") ].each do |file|
  require File.basename(file)
end

def app
  Loctrack
end

RSpec.configure do |config|
  config.include Rack::Test::Methods

  # Drop all collections and clear the identity map before each spec.
  config.before(:each) do
    Mongoid.purge!
    Mongoid::IdentityMap.clear
  end
end
