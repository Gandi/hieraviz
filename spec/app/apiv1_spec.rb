require 'spec_helper'
require 'sinatra_helper'

describe HieravizApp::ApiV1 do

  def app() 
    described_class
  end

  context "when no creds" do
    describe "GET /v1/nodes" do
      it "replies error" do
        get '/nodes'
        expect(last_response).not_to be_ok
      end
    end
  end

  context "with proper creds" do
    before do
      allow(Hieraviz::Store).
        to receive(:get).
        with('sada', 3600).
        and_return({})
    end
    describe "GET /v1/nodes" do
      it "replies error" do
        current_session.rack_session[:access_token] = 'sada'
        get '/nodes'
        expect(last_response).to be_ok
      end
    end
  end

end
