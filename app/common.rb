require 'sinatra/base'
require 'dotenv'
require 'hieracles'
require 'hieraviz'

module HieravizApp
  class Common < Sinatra::Base

    configure do
      set :app_name, 'HieraViz'
      configfile = ENV['HIERAVIZ_CONFIG_FILE'] || File.join("config", "hieraviz.yml")
      configfile = File.join(root, configfile) unless configfile[0] == '/'
      set :configfile, configfile
      set :config, YAML.load_file(configfile)
      enable :session
      enable :logging
      set :store, Hieraviz::Store.new
    end

  end
end
