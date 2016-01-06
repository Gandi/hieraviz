require 'spec_helper'
require 'sinatra_helper'

describe HieravizApp::Web do

  context "when GET /" do
    it "replies 401" do
      get '/'
      expect(last_response.status).to be 401
    end
  end

end
