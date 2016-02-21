require 'sinatra_helper'

describe HieravizApp::Web do

  context "without creds" do
    describe "GET /" do
      before { get '/' }
      it { expect(last_response.status).to eq 401 }
    end
  end

  context "with proper creds" do
    before do
      basic_authorize 'toto', 'toto'
    end
    describe "GET /" do
      before { get '/' }
      it { expect(last_response.status).to eq 200 }
      it { expect(last_response.body).to include 'Welcome to hieraviz' }
    end
    describe "GET /logout" do
      before { get '/logout' }
      it { expect(last_response.body).to include 'Please login again' }
    end
    describe "GET /nodes" do
      before { get '/nodes' }
      it { expect(last_response.body).to include 'node1.example.com' }
    end
    describe "GET /farms" do
      before { get '/farms' }
      it { expect(last_response.body).to include 'farm1' }
    end
    describe "GET /modules" do
      before { get '/modules' }
      it { expect(last_response.body).to include 'Work In Progress' }
    end
    describe "GET /resources" do
      before { get '/resources' }
      it { expect(last_response.body).to include 'Work In Progress' }
    end
    describe "GET /tata/toto" do
      before { get '/tata/toto' }
      it { expect(last_response.status).to eq 404 }
      it { expect(last_response.body).to include 'Page not found' }
    end
    describe "GET /user" do
      before { get '/user' }
      it { expect(last_response.body).to include 'toto' }
    end
  end

end
