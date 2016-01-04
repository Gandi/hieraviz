require 'sinatra/content_for'

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

    helpers do
      def oauth_client
        @_client ||= OAuth2::Client.new(
          settings.configdata['oauth2_auth']['application_id'], 
          settings.configdata['oauth2_auth']['secret'], 
          :site => settings.configdata['oauth2_auth']['host']
          )
      end
      def get_response(url)
        access_token = OAuth2::AccessToken.new(oauth_client, session[:access_token])
        begin
          JSON.parse(access_token.get(url).body)
        rescue Exception => e
          { 'error' => e.mess}
        end
      end
      def redirect_uri
        uri = URI.parse(request.url)
        uri.path = '/logged-in'
        uri.query = nil
        uri.to_s
      end
      def authorize
        if settings.configdata['auth_method'] == 'oauth2' &&
            settings.configdata['oauth2_auth']['resource_required']
          resp = get_response(settings.configdata['oauth2_auth']['resource_required'])
          logger.info resp
          if !resp[settings.configdata['oauth2_auth']['required_response_key']] ||
             resp[settings.configdata['oauth2_auth']['required_response_key']] != 
             resp[settings.configdata['oauth2_auth']['required_response_value']]
            redirect '/'
          end
        end
      end
    end

    case settings.configdata['auth_method']
    when 'http'

      use Rack::Auth::Basic, "Puppet Private Access" do |username, password|
        username == settings.configdata['http_auth']['username'] && 
        password == settings.configdata['http_auth']['password']
      end

    when 'oauth2'

      get '/login' do
        redirect oauth_client.auth_code.authorize_url(:redirect_uri => redirect_uri)
      end

      get '/logged-in' do
        authcode = oauth_client.auth_code
        logger.info authcode
        access_token = authcode.get_token(params[:code], :redirect_uri => redirect_uri)
        session[:access_token] = access_token.token
        # logger.info session['access_token']
        @message = "Successfully authenticated with the server"
        redirect '/'
      end

    else
    end


    get '/' do
      @sess = session['access_token']
      # logger.info @sess
      erb :home
    end

    get '/nodes' do
      authorize
      @nodes = Hieracles::Registry.nodes(settings.config)
      erb :nodes
    end

    get '/farms' do
      @farms = Hieracles::Registry.farms(settings.config)
      erb :farms
    end

    get '/modules' do
      erb :modules
    end

    get '/resources' do
      erb :resources
    end

    get '/logout' do
      erb :logout, layout: :_layout
    end

    not_found do
      erb :not_found, layout: :_layout
    end

    error 401 do
      'Access forbidden'
    end

  end
end
