require 'spec_helper'
require 'sinatra_helper'

describe HieravizApp::Web do

  context "with simple http auth" do
    describe "GET /" do
      it "replies 401" do
        get '/'
        expect(last_response.status).to eq 401
      end
    end
  end

  context "with gitlab auth" do
    before do
      ENV['HIERAVIZ_CONFIG_FILE'] = File.expand_path '../../files/config_gitlab.yml', __FILE__
    end
    describe "GET /" do
      it "replies 200" do
        get '/'
        pp last_response
        expect(last_response.status).to eq 200
      end
    end
  end

end
