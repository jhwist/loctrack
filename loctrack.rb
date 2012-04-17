class Counter
  include Mongoid::Document

  field :count, :type => Integer

  def self.increment
    c = first || new({:count => 0})
    c.inc(:count, 1)
    c.save
    c.count
  end
end

class Loctrack < Sinatra::Base
  configure do
    set :root, File.dirname(__FILE__)
    register Sinatra::AssetPack
    assets {
      serve '/js',     :from => 'app/js'
      serve '/css',    :from => 'app/css'
      serve '/images', :from => 'app/images'

      js :app, '/js/app.js', [
        '/js/vendor/**/*.js',
        '/js/app/**/*.js'
      ]
      css :app, '/css/app.css', [
        '/css/main.css'
      ]
    }
  end
  Mongoid.configure do |config|
    if ENV['MONGOHQ_URL']
      conn = Mongo::Connection.from_uri(ENV['MONGOHQ_URL'])
      uri = URI.parse(ENV['MONGOHQ_URL'])
      config.master = conn.db(uri.path.gsub(/^\//, ''))
    else
      config.master = Mongo::Connection.from_uri("mongodb://localhost:27017").db('test')
    end
  end

  get '/' do
    @counter = Counter.increment.to_s
    erb :index
  end
end
