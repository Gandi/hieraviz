require 'spec_helper'

describe HieravizApp::Web do

  context "when GET /" do
    it "replies 401" do
      puts app.config
      get '/'
      expect(last_response.status).to be 401
    end
  end

end
