require 'sinatra/base'
require 'dotenv'

module HieravizApp
  class Common < Sinatra::Base

    configure do
      set :app_name, 'HieraViz'
      set :configdata, Hieraviz::Config.load
      set :config, Hieracles::Config.new({ config: Hieraviz::Config.configfile })
      enable :session
      enable :logging
    end

  end
end
