require 'spec_helper'
require 'sinatra_helper'

describe HieravizApp::ApiV1 do

  context "page not found" do
    describe "GET /v1/blahblah" do
      let(:expected) { { 'error' => "endpoint not found" }  }
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
    describe "GET /v1/node/node1.example.com/info" do
      let(:expected) {
        {
          'classes' => ['farm1'],
          'country' => 'fr',
          'datacenter' => 'equinix',
          'farm' => 'dev',
          'fqdn' => 'node1.example.com'
        }
      }
      before do
        get '/node/node1.example.com/info'
      end
      it { expect(last_response).to be_ok }
      it { expect(JSON.parse last_response.body).to eq expected }
    end
    describe "GET /v1/node/node1.example.com/params" do
      let(:expected) {
        {
          "param1.subparam1" => {
            "value" => "value1", 
            "file" => "params/nodes/node1.example.com.yaml", 
            "overriden" => false, 
            "found_in" => [
              {
                "value"=>"value1", 
                "file"=>"params/nodes/node1.example.com.yaml"
              }
            ]
          }
        }
      }
      before do
        get '/node/node1.example.com/params'
      end
      it { expect(last_response).to be_ok }
      it { expect(JSON.parse last_response.body).to eq expected }
    end
    describe "GET /v1/node/node1.example.com" do
      let(:expected) {
        {
          "param1.subparam1" => {
            "value" => "value1", 
            "file" => "params/nodes/node1.example.com.yaml", 
            "overriden" => false, 
            "found_in" => [
              {
                "value"=>"value1", 
                "file"=>"params/nodes/node1.example.com.yaml"
              }
            ]
          }
        }
      }
      before do
        get '/node/node1.example.com'
      end
      it { expect(last_response).to be_ok }
      it { expect(JSON.parse last_response.body).to eq expected }
    end
    describe "GET /v1/node/node1.example.com/allparams" do
      let(:expected) {
         {
          "param1.subparam1" => {
            "value" => "value1", 
            "file" => "-", 
            "overriden" => true, 
            "found_in" => [
              {
                "value" => "value1", 
                "file" => "params/nodes/node1.example.com.yaml"
              },
              {
                "value" => "value common", 
                "file"=>"params/common/common.yaml"
              }
            ]
          },
          "param2.subparam2" => {
            "value" => "another value", 
            "file"=>"params/common/common.yaml", 
            "overriden" => false, 
            "found_in" => [
              {
                "value" => "another value", 
                "file"=>"params/common/common.yaml"
              }
            ]
          }
        }
      }
      before do
        get '/node/node1.example.com/allparams'
      end
      it { expect(last_response).to be_ok }
      it { expect(JSON.parse last_response.body).to eq expected }
    end
    describe "GET /v1/farms" do
      let(:expected) { { "farm1" => 0 } }
      before do
        get '/farms'
      end
      it { expect(last_response).to be_ok }
      it { expect(JSON.parse last_response.body).to eq expected }
    end
    describe "GET /v1/vars" do
      let(:expected) { ['fqdn', 'farm'] }
      before do
        get '/vars'
      end
      it { expect(last_response).to be_ok }
      it { expect(JSON.parse last_response.body).to eq expected }
    end
  end

end
