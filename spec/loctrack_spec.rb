require 'spec_helper'

describe 'Location Tracking' do
  describe 'API' do
  end

  describe 'UI' do
    it "responds to GET" do
      get '/'
      last_response.should be_ok
    end
  end
end
