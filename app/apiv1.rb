require 'sinatra/json'

require 'digest/sha1'
require 'dotenv'
require 'yajl'

require 'hieracles'
require 'hieraviz'

require File.expand_path '../common.rb', __FILE__

module HieravizApp
  class ApiV1 < Common

    configure do
      set :session_secret, settings.configdata['session_seed']
      enable :sessions
    end

    helpers do
      def check_authorization
        if !session['access_token'] && !request.env['HTTP_X_AUTH']
          redirect '/v1/not_logged'
        else
          token = session['access_token'] || request.env['HTTP_X_AUTH']
          session_info = Hieraviz::Store.get(token, settings.configdata['session_renew'])
          if !session_info
            redirect '/v1/unauthorized'
          end
        end
      end
    end

    get '/:base/nodes' do |base|
      check_authorization
      json Hieracles::Registry.nodes(settings.config)
    end

    get '/:base/node/:n/info' do |base, node|
      check_authorization
      node = Hieracles::Node.new(node, settings.config)
      json node.info
    end

    get '/:base/node/:n/params' do |base, node|
      check_authorization
      node = Hieracles::Node.new(node, settings.config)
      json node.params
    end

    get '/:base/node/:n/allparams' do |base, node|
      check_authorization
      node = Hieracles::Node.new(node, settings.config)
      json node.params(false)
    end

    get '/:base/node/:n' do |base, node|
      check_authorization
      pp settings.config
      hieracles_config = prepare_base(node, base)
      node = Hieracles::Node.new(node, hieracles_config)
      json node.params
    end

    get '/:base/farms' do |base|
      check_authorization
      json Hieracles::Registry.farms(settings.config)
    end

    # get '/farm/:n' do |farm|
    #   check_authorization
    #   req = Hieracles::Puppetdb::Request.new(settings.configdata['puppetdb'])
    #   farm_nodes = req.facts('farm', farm)
    #   json farm_nodes.data
    # end

    get '/not_logged' do
      json({ error: "Not connected." })
    end

    get '/unauthorized' do
      json({ error: "Unauthorized" })
    end

    not_found do
      json({ error: "data not found" })
    end

  end
end
