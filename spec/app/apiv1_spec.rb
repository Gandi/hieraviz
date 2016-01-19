require 'spec_helper'
require 'sinatra_helper'

describe HieravizApp::ApiV1 do

  context "page not found" do
    describe "GET /v1/blahblah" do
      let(:expected) { { 'error' => "data not found" }  }
      before do
        get '/blahblah'
      end
      it { expect(last_response).not_to be_ok }
      it { expect(JSON.parse last_response.body).to eq expected }
    end
  end

  context "when no creds" do
    describe "GET /v1/nodes" do
      let(:expected) { 'http://example.org/v1/not_logged' }
      before do
        get '/nodes'
      end
      it { expect(last_response).not_to be_ok }
      it { expect(last_response.header['Location']).to eq expected }
    end
    describe 'GET /v1/not_logged' do
      let(:expected) { { 'error' => "Not connected." }  }
      before do
        get '/not_logged'
      end
      it { expect(last_response).to be_ok }
      it { expect(JSON.parse last_response.body).to eq expected }
    end
  end

  context "with creds but no perms" do
    describe "GET /v1/nodes" do
      let(:expected) { 'http://example.org/v1/unauthorized' }
      before do
        current_session.rack_session[:access_token] = 'sada'
        allow(Hieraviz::Store).
          to receive(:get).
          with('sada', 3600).
          and_return(false)
        get '/nodes'
      end
      it { expect(last_response).not_to be_ok }
      it { expect(last_response.header['Location']).to eq expected }
    end
    describe 'GET /v1/unauthorized' do
      let(:expected) { { 'error' => "Unauthorized" }  }
      before do
        get '/unauthorized'
      end
      it { expect(last_response).to be_ok }
      it { expect(JSON.parse last_response.body).to eq expected }
    end
  end

  context "with proper creds" do
    before do
      current_session.rack_session[:access_token] = 'sada'
      allow(Hieraviz::Store).
        to receive(:get).
        with('sada', 3600).
        and_return({})
    end
    describe "GET /v1/nodes" do
      let(:expected) { ['node1.example.com'] }
      before do
        get '/nodes'
      end
      it { expect(last_response).to be_ok }
      it { expect(JSON.parse last_response.body).to eq expected }
    end
    describe "GET /v1/farms" do
      let(:expected) { ['farm1'] }
      before do
        get '/farms'
      end
      it { expect(last_response).to be_ok }
      it { expect(JSON.parse last_response.body).to eq expected }
    end
  end

end
