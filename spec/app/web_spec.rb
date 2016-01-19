require 'spec_helper'
ENV['HIERAVIZ_CONFIG_FILE'] = File.expand_path '../../files/config.yml', __FILE__
require 'sinatra_helper'

describe HieravizApp::Web do

  def app() 
    described_class
  end

  describe "GET /" do
    it "replies 401" do
      get '/'
      expect(last_response.status).to eq 401
    end
  end


end
