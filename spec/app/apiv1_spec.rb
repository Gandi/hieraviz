require 'spec_helper'
require 'sinatra_helper'

describe HieravizApp::ApiV1 do

  context "without any auth" do
    context "when GET /v1/nodes" do
      it "replies error" do
        get '/nodes'
        expect(last_response).not_to be_ok
      end
    end
  end

end
