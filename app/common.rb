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

      case settings.configdata['auth_method']
      when 'dummy'

        def get_username
          'Dummy'
        end
        def get_userinfo
          { 'username' => 'Dummy' }
        end

      when 'http'

        def get_username
          settings.configdata['http_auth']['username']
        end
        def get_userinfo
          { 'username' => settings.configdata['http_auth']['username'] }
        end

      when 'gitlab'
        
        def get_username
          if session['access_token']
            session_info = Hieraviz::Store.get(session['access_token'], settings.configdata['session_renew'])
            if session_info
              session_info['username']
            else
              ''
            end
          end
        end
        def get_userinfo
          Hieraviz::Store.get(session['access_token'], settings.configdata['session_renew'])
        end
      end

      def prepare_config(e, node = nil)
        e ||= File.basename(settings.configdata['basepath'])
        path = get_path(e)[0]
        if path
          @base = get_base(path)
          @base_name = @base.gsub(/\//,'')
          get_config(path, cached_params(e, node))
        end
      end

      def cached_params(base, node)
        if node
          cache = Hieraviz::Facts.new settings.configdata['tmpdir'], base, node, get_username
          if cache.exist?
            return cache.read
          end
        end
        {}
      end

      def prepare_params(e)
        e ||= File.basename(settings.configdata['basepath'])
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
      
      def get_config(path, extra)
        args = { config: Hieraviz::Config.configfile }
        if path
          args[:basepath] = path
        end
        if extra.length > 0
          args[:params] = format_params(extra)
        end
        Hieracles::Config.new args
      end

      def get_base(path)
        "/#{File.basename(path)}"
      end

      def format_params(params)
        params.reduce([]) do |a, (k, v)|
          a << "#{k}=#{v}"
          a
        end.join(',')
      end

    end

  end
end
