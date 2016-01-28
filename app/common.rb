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
      def prepare_config(e)
        e = File.basename(settings.configdata['basepath']) unless e
        path = get_path(e)[0]
        if path
          @base = get_base(path)
          @base_name = @base.gsub(/\//,'')
          get_config(path)
        end
      end
      def prepare_params(e)
        e = File.basename(settings.configdata['basepath']) unless e
        path = get_path(e)[0]
        if path
          settings.configdata['basepath'] = path
          settings.configdata
        end        
      end
      def get_path(path)
        if settings.basepaths
          settings.basepaths.select do |p|
            path == File.basename(p)
          end
        else
          [ settings.configdata['basepath'] ]
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
      def get_base(path)
        "/#{File.basename(path)}"
      end
    end

  end
end
