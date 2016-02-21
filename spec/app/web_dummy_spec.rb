require 'sinatra_dummy_helper'

describe HieravizApp::Web do

  context "when using dummy auth" do
    describe "GET /login" do
      before { get '/login' }
      it { expect(last_response.status).to eq 302 }
    end
    describe "GET /logout" do
      before { get '/logout' }
      it { expect(last_response.status).to eq 200 }
    end
  end

end
