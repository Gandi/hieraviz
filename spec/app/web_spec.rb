require 'spec_helper'
require 'sinatra_helper'

describe HieravizApp::Web do

  describe "GET /" do
    it "replies 401" do
      get '/'
      expect(last_response.status).to eq 401
    end
  end


end
