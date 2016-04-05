require 'sinatra/content_for'

# require 'better_errors'
require 'rack-flash'
require 'dotenv'
require 'oauth2'

require 'hieracles'
require 'hieraviz'

require File.expand_path '../common.rb', __FILE__

module HieravizApp
  # the unique web endpoints management
  class Web < Common
    helpers Sinatra::ContentFor
    use Rack::Flash

    configure do
      set :session_secret, settings.configdata['session_seed']
      set :public_folder, -> { File.join(root, 'public') }
      set :views_folder, -> { File.join(root, 'views') }
      set :erb, layout: :_layout
      enable :sessions
    end

    configure :development do
      use BetterErrors::Middleware
      BetterErrors.application_root = File.expand_path('../../', __FILE__)
    end

    case settings.configdata['auth_method']
    when 'dummy'

      get '/logout' do
        session.delete 'access_token'
        erb :logout
      end

      get '/login' do
        session['access_token'] = '0000'
        redirect '/'
      end

      helpers do
        def check_authorization
          if session['access_token']
            return 'dummy'
          end
          false
        end
      end

    when 'http'

      use Rack::Auth::Basic, 'Puppet Private Access' do |user, pass|
        user == settings.configdata['http_auth']['username'] &&
          pass == settings.configdata['http_auth']['password']
      end

      get '/logout' do
        erb :logout
      end

      helpers do
        def check_authorization
          http_auth = settings.configdata['http_auth']
          unless session['access_token']
            session[:access_token] = http_auth['access_token']
          end
          http_auth['username']
        end
      end

    when 'gitlab'

      set :oauth, Hieraviz::AuthGitlab.new(settings.configdata['gitlab_auth'])

      helpers do
        def check_authorization
          if session_info['username']
            session_info['username']
          else
            access_token = session['access_token']
            oauth = settings.oauth
            redirect oauth.login_url(request) unless access_token
            return init_session(oauth, access_token) if oauth.authorized?(access_token)
            sorry
          end
        end

        def session_info
          settings.store.get session['access_token'], settings.configdata['session_renew']
        end

        def init_session(oauth, access_token)
          user_info = oauth.user_info(access_token)
          settings.store.set access_token, user_info
          user_info['username']
        end

        def sorry
          flash[:fatal] = 'Sorry you are not authorized to read puppet repo on gitlab.'
          redirect '/'
        end
      end

      get '/login' do
        redirect settings.oauth.login_url(request)
      end

      get '/logged-in' do
        access_token = settings.oauth.access_token(request, params[:code])
        session[:access_token] = access_token.token
        settings.store.set access_token.token, settings.oauth.user_info(access_token.token)
        flash[:info] = 'Successfully authenticated with the server'
        redirect '/'
      end

      get '/logout' do
        session.clear
        redirect '/'
      end

    end

    get '/' do
      if settings.basepaths
        redirect "/#{File.basename(settings.configdata['basepath'])}"
      else
        @username = username
        erb :home
      end
    end

    get %r{^/?([-_\.a-zA-Z0-9]+)?/nodes} do |base|
      @username = check_authorization
      hieracles_config = prepare_config(base)
      @nodes = Hieracles::Registry.nodes(hieracles_config)
      erb :nodes
    end

    get %r{^/?([-_\.a-zA-Z0-9]+)?/farms} do |base|
      @username = check_authorization
      hieracles_config = prepare_config(base)
      @farms = Hieracles::Registry.farms_counted(hieracles_config, base)
      erb :farms
    end

    get %r{^/?([-_\.a-zA-Z0-9]+)?/modules} do |base|
      prepare_config(base)
      @username = check_authorization
      erb :modules
    end

    get %r{^/?([-_\.a-zA-Z0-9]+)?/resources} do |base|
      prepare_config(base)
      @username = check_authorization
      erb :resources
    end

    get %r{^/?([-_\.a-zA-Z0-9]+)?/user} do |base|
      prepare_config(base)
      @username = check_authorization
      @userinfo = session[:access_token] ? userinfo : {}
      erb :user
    end

    get %r{^/([-_\.a-zA-Z0-9]+)$} do |base|
      prepare_config(base)
      @username = username
      erb :home
    end

    # debug pages --------------------
    # get '/store' do
    #   # settings.store.set 'woot', 'nada'
    #   erb :store
    # end
    # error 401 do
    #   'Access forbidden'
    # end
    # get '/paths' do
    #   @data = settings.basepaths.map { |p| File.basename(p) }
    #   erb :data
    # end
    # debug pages --------------------

    not_found do
      @username = username
      erb :not_found, layout: :_layout
    end

  end
end
