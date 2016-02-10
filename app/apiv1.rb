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

    get %r{^/?([-_\.a-zA-Z0-9]+)?/nodes} do |base|
      check_authorization
      hieracles_config = prepare_config(base)
      json Hieracles::Registry.nodes(hieracles_config)
    end

    get %r{^/?([-_\.a-zA-Z0-9]+)?/node/([-_\.a-zA-Z0-9]+)/info} do |base, node|
      check_authorization
      hieracles_config = prepare_config(base)
      node = Hieracles::Node.new(node, hieracles_config)
      json node.info
    end

    get %r{^/?([-_\.a-zA-Z0-9]+)?/node/([-_\.a-zA-Z0-9]+)/params} do |base, node|
      check_authorization
      hieracles_config = prepare_config(base)
      node = Hieracles::Node.new(node, hieracles_config)
      json node.params
    end

    get %r{^/?([-_\.a-zA-Z0-9]+)?/node/([-_\.a-zA-Z0-9]+)/allparams} do |base, node|
      check_authorization
      hieracles_config = prepare_config(base)
      node = Hieracles::Node.new(node, hieracles_config)
      json node.params(false)
    end

    get %r{^/?([-_\.a-zA-Z0-9]+)?/node/([-_\.a-zA-Z0-9]+)$} do |base, node|
      check_authorization
      hieracles_config = prepare_config(base)
      node = Hieracles::Node.new(node, hieracles_config)
      json node.params
    end

    get %r{^/?([-_\.a-zA-Z0-9]+)?/farms} do |base|
      check_authorization
      hieracles_config = prepare_config(base)
      json Hieracles::Registry.farms(hieracles_config)
    end

    get %r{^/?([-_\.a-zA-Z0-9]+)?/vars} do |base|
      check_authorization
      hieracles_config = prepare_config(base)
      hiera = Hieracles::Hiera.new(hieracles_config)
      json hiera.params
    end

    get %r{^/?([-_\.a-zA-Z0-9]+)?/node/([-_\.a-zA-Z0-9]+)/hierarchy} do |base, node|
      check_authorization
      hieracles_config = prepare_config(base)
      hiera = Hieracles::Hiera.new(hieracles_config)
      node = Hieracles::Node.new(node, hieracles_config)
      res = { 
        'hiera'    => hiera.hierarchy,
        'vars'     => hiera.params,
        'info'     => node.info,
        'files'    => node.files,
        'defaults' => settings.configdata['defaultscope']
      }
      json res
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
      json({ error: "endpoint not found" })
    end

  end
end
