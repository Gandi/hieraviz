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
          settings.config['oauth2_auth']['application_key'], 
          settings.config['oauth2_auth']['secret'], 
          :site => settings.config['oauth2_auth']['host']
          )
      end
      def get_response(url)
        access_token = OAuth2::AccessToken.new(oauth_client, session[:access_token])
        JSON.parse(access_token.get("/api/v1/#{url}").body)
      end
      def redirect_uri
        uri = URI.parse(request.url)
        uri.path = '/logged-in'
        uri.query = nil
        uri.to_s
      end
    end

    use Rack::Auth::Basic, "Puppet Private Access" do |username, password|
      username == settings.configdata['http_auth']['username'] && 
      password == settings.configdata['http_auth']['password']
    end


    get '/' do
      erb :home
    end

    get '/nodes' do
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

    get '/login' do
      redirect client.auth_code.authorize_url(:redirect_uri => redirect_uri)
    end

    get '/logged-in' do
      access_token = client.auth_code.get_token(params[:code], :redirect_uri => redirect_uri)
      session[:access_token] = access_token.token
      @message = "Successfully authenticated with the server"
      redirect '/'
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
