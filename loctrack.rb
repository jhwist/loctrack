require 'sinatra'

class Application < Sinatra::Base
  configure do
    puts "Test for configure"
  end
  Mongoid.configure do |config|
    puts ENV['MONGOHQ_URL']
    if ENV['MONGOHQ_URL']
      conn = Mongo::Connection.from_uri(ENV['MONGOHQ_URL'])
      uri = URI.parse(ENV['MONGOHQ_URL'])
      config.master = conn.db(uri.path.gsub(/^\//, ''))
    else
      config.master = Mongo::Connection.from_uri("mongodb://localhost:27017").db('test')
    end
  end
  get '/' do
    'Hello World'
    ENV
  end
end
