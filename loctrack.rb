require 'rubygems'
require 'sinatra'
require 'sinatra/assetpack'
require 'gon-sinatra'
require 'mongoid'

class Location
  include Mongoid::Document
  include Mongoid::Timestamps
  field :where, :type => :Array
end

class Loctrack < Sinatra::Base
  configure do
    set :root, File.dirname(__FILE__)
    register Gon::Sinatra
    register Sinatra::AssetPack
    assets {
      serve '/js',     :from => 'app/js'
      serve '/css',    :from => 'app/css'
      serve '/images', :from => 'app/images'

      js :app, '/js/app.js', [
        '/js/vendor/**/*.js',
        '/js/gmaps.js'
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
      config.master = Mongo::Connection.from_uri("mongodb://localhost:27017").db('locations')
    end
  end

  get '/api/v1/parked/:id' do
    loc = Location.get(params[:id])
    if loc.nil? then
      status 404
    else
      status 200
      body(loc.to_json)
    end
  end

  # curl -i -H "Accept: application/json" -X POST -d '{"loc":"48.11,11.6"}' http://localhost:5000/api/v1/parked
  post '/api/v1/parked' do
    data = JSON.parse(request.body.gets.as_json)
    loc = data["loc"]
    if loc.nil?
      status 404
    else
      lat,long = loc.split(",").map{|x| x.to_f}
      parked_at = Location.new(:where => [lat,long])
      parked_at.save!
      status 200
      body("Thanks, got you at #{loc}\n")
    end
  end


  get '/' do
    gon.locations = [['15-02-2012 - 07.50',  48.05514872074127,11.663317680358887],
['16-02-2012 - 08.31',  48.148478865623474,11.743971705436707],
['16-02-2012 - 17.31',  48.148478865623474,11.743971705436707],
['16-02-2012 - 17.58',  48.06323289871216,11.671809554100037],
['17-02-2012 - 08.20',  48.05216073989868,11.670361161231995],
['17-02-2012 - 08.38',  48.1486451625824,11.74436330795288],
['17-02-2012 - 17.50',  48.06295931339264,11.67273759841919],
['18-02-2012 - 14.15',  48.06298077106476,11.6722172498703],
['18-02-2012 - 17.30',  47.344969511032104,13.389989733695984],
['18-02-2012 - 17.51',  47.35533356666565,13.389034867286682],
['25-02-2012 - 10.32',  47.34489440917969,13.390139937400818],
['25-02-2012 - 11.48',  47.58453369140625,13.157925009727478],
['25-02-2012 - 13.27',  47.82925307750702,12.589704394340515],
['25-02-2012 - 14.47',  48.06294322013855,11.67249619960785]
]
    erb :index
  end
end
