require 'sinatra/base'
require 'sinatra/json'
require 'sinatra/content_for'

require 'better_errors'
require 'digest/sha1'
require 'dotenv'
require 'yajl'

require 'hieracles'
require 'hieraviz'

class Common < Sinatra::Base

  configure do
    set :app_name, 'HieraViz'
    set :configfile, ENV['HIERAVIZ_CONFIG_FILE'] || File.join(root, "config", "hieraviz.yml")
    set :config, YAML.load_file(configfile)
    enable :session
    enable :logging
    set :store, Hieraviz::Store.new
  end

end

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


class Api < Common

  get '/test' do
    json data: Time.new 
  end

  get '/nodes' do
    config = Hieracles::Config.new(settings.config)
    json Hieracles::Registry.nodes(config)
  end

  get '/node/:n/info' do |node|
    config = Hieracles::Config.new(settings.config)
    node = Hieracles::Node.new(node, config)
    json node.info
  end

  get '/node/:n/params' do |node|
    config = Hieracles::Config.new(settings.config)
    node = Hieracles::Node.new(node, config)
    json node.params
  end

  get '/node/:n/allparams' do |node|
    config = Hieracles::Config.new(settings.config)
    node = Hieracles::Node.new(node, config)
    json node.params(false)
  end

  get '/node/:n' do |node|
    config = Hieracles::Config.new(settings.config)
    node = Hieracles::Node.new(node, config)
    json node.params
  end

  get '/farms' do
    config = Hieracles::Config.new(settings.config)
    json Hieracles::Registry.farms(config)
  end

  get '/farm/:n' do |farm|
    req = Hieracles::Puppetdb::Request.new(settings.config['puppetdb'])
    farm_nodes = req.facts('farm', farm)
    json farm_nodes.data
  end

  not_found do
    json({ error: "data not found" })
  end

end
