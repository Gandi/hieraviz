require 'sinatra/base'
require 'dotenv'
require 'hieracles'
require 'hieraviz'

module HieravizApp
  class Common < Sinatra::Base

    configure do
      set :app_name, 'HieraViz'
      set :configfile, ENV['HIERAVIZ_CONFIG_FILE'] || File.join(root, "config", "hieraviz.yml")
      set :config, YAML.load_file(configfile)
      enable :session
      enable :logging
      set :store, Hieraviz::Store.new
    end

  end
end
