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

    helpers do

      def oauth_client
        @_client ||= OAuth2::Client.new(
          settings.configdata['oauth2_auth']['application_id'], 
          settings.configdata['oauth2_auth']['secret'], 
          :site => settings.configdata['oauth2_auth']['host']
          )
      end

      def get_response(url)
        access_token = OAuth2::AccessToken.new(oauth_client, session['access_token'])
        begin
          JSON.parse(access_token.get(url).body)
        rescue Exception => e
          { 'error' => JSON.parse(e.message.split(/\n/)[1])['message'] }
        end
      end

      def redirect_uri
        uri = URI.parse(request.url)
        uri.path = '/logged-in'
        uri.query = nil
        uri.to_s
      end

      def check_authorization
        if settings.configdata['auth_method'] == 'oauth2' &&
            settings.configdata['oauth2_auth']['resource_required']
          resp = get_response(settings.configdata['oauth2_auth']['resource_required'])
          logger.info resp
          if resp['error'] ||
             (resp[settings.configdata['oauth2_auth']['required_response_key']] &&
             resp[settings.configdata['oauth2_auth']['required_response_key']] != 
             resp[settings.configdata['oauth2_auth']['required_response_value']])
             logger.info resp['error']
            flash[:fatal] = resp['error']
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

    when 'gitlab'

      set :oauth, Hieraviz::AuthGitlab.new(settings.configdata['oauth2_auth'], session)

      get '/login' do
        redirect settings.oauth.login_url
      end

      get '/logged-in' do
        authcode = oauth_client.auth_code
        access_token = authcode.get_token(params[:code], :redirect_uri => redirect_uri)
        session[:access_token] = access_token.token
        flash['info'] = "Successfully authenticated with the server"
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

    get '/logout' do
      erb :logout, layout: :_layout
    end

    not_found do
      session[:access_token] =
      erb :not_found, layout: :_layout
    end

    error 401 do
      'Access forbidden'
    end

  end
end
