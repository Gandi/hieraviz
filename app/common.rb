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
      def prepare_env(e, r)
        @username = check_authorization
        path = validate_basepath(e, r)
        @env = get_env(path)
        if @env == ''
          @env_name = File.basename(settings.configdata['basepath'])
        else
          @env_name = @env.gsub(/\//,'')
        end
        get_config(path)
      end
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
      def get_config(path)
        if path
          Hieracles::Config.new({ 
            config: Hieraviz::Config.configfile,
            basepath: path
            })
        else
          Hieracles::Config.new({ 
            config: Hieraviz::Config.configfile
            })
        end     
      end
      def get_env(path)
        if path
          "/#{File.basename(path)}"
        else
          ''
        end
      end
    end

  end
end
