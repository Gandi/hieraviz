require 'sinatra/content_for'

require 'better_errors'
require 'digest/sha1'
require 'dotenv'

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
    end

    configure :development do
      use BetterErrors::Middleware
      BetterErrors.application_root = File.expand_path('..', __FILE__)
    end

    helpers do
      def check_cookie
        if !session[:hieraviz_key]
          newkey = Digest::SHA1.hexdigest(Time.new.to_s)
          store.set(:hieraviz_key, newkey)
          session[:hieraviz_key] = newkey
        end
      end
      def verify_key(key)
        
      end
    end

    use Rack::Auth::Basic, "Puppet Private Access" do |username, password|
      username == settings.config['http_auth']['username'] && 
      password == settings.config['http_auth']['password']
    end


    get '/' do
      erb :home
    end

    get '/nodes' do
      config = Hieracles::Config.new(settings.config)
      @nodes = Hieracles::Registry.nodes(config)
      erb :nodes
    end

    get '/farms' do
      config = Hieracles::Config.new(settings.config)
      @farms = Hieracles::Registry.farms(config)
      erb :farms
    end

    get '/modules' do
      erb :farms
    end

    get '/resources' do
      erb :farms
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
