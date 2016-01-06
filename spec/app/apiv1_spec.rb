require 'spec_helper'
require 'sinatra_helper'

describe HieravizApp::ApiV1 do

  context "when GET /v1/nodes" do
    it "replies 200" do
      get '/nodes'
      expect(last_response).to be_ok
    end
  end

end
