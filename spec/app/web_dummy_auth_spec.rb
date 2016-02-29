require 'sinatra_helper'

describe HieravizApp::Web do
  before do
    ENV['HIERAVIZ_CONFIG_FILE'] = File.expand_path '../../files/config_dummy.yml', __FILE__
    app.set :configdata, Hieraviz::Config.load
    app.set :basepaths, Hieraviz::Config.basepaths
    app.set :store, Hieraviz::Store.new(app.settings.configdata['tmpdir'])
  end
  
end
