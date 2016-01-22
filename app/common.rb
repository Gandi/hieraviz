require 'sinatra/base'
require 'dotenv'

module HieravizApp
  class Common < Sinatra::Base

    configure do
      set :app_name, 'HieraViz'
      set :configdata, Hieraviz::Config.load
      set :config, Hieracles::Config.new({ config: Hieraviz::Config.configfile })
      set :basepaths, Hieraviz::Config.basepaths
      enable :session
      enable :logging
    end

    helpers do
      def get_path(path)
        if settings.basepaths
          settings.basepaths.select do |p|
            path == File.basename(p)
          end
        end
      end
      def validate_basepath(path, url)
        if path
          if get_path(path)
            get_path(path)[0]
          else
            redirect url
          end
        end
      end
    end

  end
end
