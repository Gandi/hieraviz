require 'sinatra/content_for'
require 'sinatra/flash'

require 'better_errors'
require 'dotenv'
require 'oauth2'

require 'hieracles'
require 'hieraviz'

require File.expand_path '../common.rb', __FILE__

module HieravizApp
  class Web < Common
    helpers Sinatra::ContentFor
    register Sinatra::Flash

    configure do
      set :session_secret, settings.configdata['session_seed']
      set :public_folder, Proc.new { File.join(root, "public") }
      set :views_folder, Proc.new { File.join(root, "views") }
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
        erb :logout, layout: :_layout
      end

      helpers do
        def check_authorization
          true
        end
      end

    when 'http'

      use Rack::Auth::Basic, "Puppet Private Access" do |username, password|
        username == settings.configdata['http_auth']['username'] && 
        password == settings.configdata['http_auth']['password']
      end

      get '/logout' do
        erb :logout, layout: :_layout
      end

      helpers do
        def check_authorization
          if !session['access_token']
            session[:access_token] = settings.configdata['http_auth']['access_token']
          end
          settings.configdata['http_auth']['username']
        end
      end

    when 'gitlab'

      set :oauth, Hieraviz::AuthGitlab.new(settings.configdata['gitlab_auth'])

      helpers do

        def check_authorization
          if !session['access_token']
            redirect settings.oauth.login_url(request)
          else
            session_info = Hieraviz::Store.get(session['access_token'], settings.configdata['session_renew'])
            if !session_info
              if !settings.oauth.authorized?(session['access_token'])
                flash[:fatal] = "Sorry you are not authorized to read puppet repo on gitlab."
                redirect '/'
              else
                Hieraviz::Store.set session['access_token'], settings.oauth.user_info(session['access_token'])
                session_info = Hieraviz::Store.get(session['access_token'], settings.configdata['session_renew'])
              end
            end
            session_info['username']
          end
        end
      end

      get '/login' do
        redirect settings.oauth.login_url(request)
      end

      get '/logged-in' do
        access_token = settings.oauth.access_token(request, params[:code])
        session[:access_token] = access_token.token
        Hieraviz::Store.set access_token.token, settings.oauth.user_info(access_token.token)
        flash['info'] = "Successfully authenticated with the server"
        redirect '/'
      end

      get '/logout' do
        session.clear
        redirect '/'
      end

    else
    end

    get '/' do
      if settings.basepaths
        redirect "/#{File.basename(settings.configdata['basepath'])}"
      else
        @username = get_username
        hieracles_config = prepare_config(nil)
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
      @username = check_authorization
      hieracles_config = prepare_config(base)
      erb :modules
    end

    get %r{^/?([-_\.a-zA-Z0-9]+)?/resources} do |base|
      @username = check_authorization
      hieracles_config = prepare_config(base)
      erb :resources
    end

    get %r{^/?([-_\.a-zA-Z0-9]+)?/user} do |base|
      @username = check_authorization
      hieracles_config = prepare_config(base)
      if session[:access_token]
        @userinfo = get_userinfo 
      else
        @userinfo = {}
      end
      erb :user
    end

    get %r{^/([-_\.a-zA-Z0-9]+)$} do |base|
      @username = get_username
      hieracles_config = prepare_config(base)
      erb :home
    end

    # debug pages --------------------
    # get '/store' do
    #   # Hieraviz::Store.set 'woot', 'nada'
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
      @username = get_username
      erb :not_found, layout: :_layout
    end


  end
end
