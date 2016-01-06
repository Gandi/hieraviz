require 'sinatra/content_for'
require 'sinatra/flash'

require 'better_errors'
require 'digest/sha1'
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
      BetterErrors.application_root = File.expand_path('..', __FILE__)
    end

    case settings.configdata['auth_method']
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
          true
        end
      end

    when 'gitlab'

      set :oauth, Hieraviz::AuthGitlab.new(settings.configdata['gitlab_auth'])

      def check_authorization
        if !session['access_token']
          redirect settings.oauth.login_url(request)
        else
          if !settings.oauth.authorized?(session['access_token'])
            flash[:fatal] = "Sorry you are not authorized to read puppet repo on gitlab."
            redirect '/'
          end
        end
      end

      get '/login' do
        redirect settings.oauth.login_url(request)
      end

      get '/logged-in' do
        access_token = settings.oauth.access_token(request, params[:code])
        session[:access_token] = access_token.token
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
      erb :home
    end

    get '/nodes' do
      check_authorization
      @nodes = Hieracles::Registry.nodes(settings.config)
      erb :nodes
    end

    get '/farms' do
      check_authorization
      @farms = Hieracles::Registry.farms(settings.config)
      erb :farms
    end

    get '/modules' do
      check_authorization
      erb :modules
    end

    get '/resources' do
      check_authorization
      erb :resources
    end

    not_found do
      erb :not_found, layout: :_layout
    end

    error 401 do
      'Access forbidden'
    end

  end
end
