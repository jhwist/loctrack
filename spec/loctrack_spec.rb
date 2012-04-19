require 'spec_helper'

describe 'Location Tracking' do
  include Rack::Test::Methods
  describe 'API' do
    let (:api) {"/api/v1"}
    it "lives under /api" do
      post '/'
      last_response.should be_not_found
    end
    describe "to record a new location" do
      it "404s on empty POST" do
        post "#{api}/parked", "{}"
        last_response.should be_not_found
      end
      it "creates a new location from valid POST data" do
        loc = mock(Location.new)
        Location.should_receive(:new).with(:where => [48.11,11.6]).and_return loc
        loc.should_receive(:save!)
        post "#{api}/parked", '{"loc" : "48.11,11.6"}'
        last_response.should be_ok
      end
    end
  end

  describe 'UI' do
    it "responds to GET" do
      get '/'
      last_response.should be_ok
    end
  end
end
