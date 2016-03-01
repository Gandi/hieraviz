require 'sinatra/base'
require 'dotenv'

module HieravizApp
  class Common < Sinatra::Base

    configure do
      set :app_name, 'HieraViz'
      set :configdata, Hieraviz::Config.load
      set :basepaths, Hieraviz::Config.basepaths
      set :store, Hieraviz::Store.new(settings.configdata['tmpdir'])
      enable :session
      enable :logging
    end

    helpers do
      case settings.configdata['auth_method']
      when 'dummy'

        def username
          'Dummy'
        end

        def userinfo
          { 'username' => 'Dummy' }
        end

      when 'http'

        def username
          settings.configdata['http_auth']['username']
        end

        def userinfo
          { 'username' => settings.configdata['http_auth']['username'] }
        end

      when 'gitlab'

        def username
          if session['access_token']
            session_info = settings.store.get(session['access_token'], settings.configdata['session_renew'])
            session_info['username'] || ''
          else
            ''
          end
        end

        def userinfo
          settings.store.get(session['access_token'], settings.configdata['session_renew'])
        end

      end

      def prepare_config(paths, node = nil)
        paths ||= File.basename(settings.configdata['basepath'])
        path = get_path(paths)[0]
        if path
          @base = get_base(path)
          @base_name = @base.gsub(%r{/}, '')
          get_config(path, cached_params(paths, node))
        end
      end

      def cached_params(base, node)
        if node
          cache = Hieraviz::Facts.new settings.configdata['tmpdir'], base, node, username
          return cache.read if cache.exist?
        end
        {}
      end

      def prepare_params(paths)
        paths ||= File.basename(settings.configdata['basepath'])
        path = get_path(paths)[0]
        return unless path
        settings.configdata['basepath'] = path
        settings.configdata
      end

      def get_path(path)
        if settings.basepaths
          settings.basepaths.select do |file|
            path == File.basename(file)
          end
        else
          [settings.configdata['basepath']]
        end
      end

      def get_config(path, extra)
        args = { config: Hieraviz::Config.configfile }
        args[:basepath] = path if path
        args[:params] = format_params(extra) unless extra.empty?
        Hieracles::Config.new args
      end

      def get_base(path)
        "/#{File.basename(path)}"
      end

      def format_params(params)
        params.each_with_object([]) do |(key, val), acc|
          acc << "#{key}=#{val}"
        end.join(',')
      end
    end

  end
end
