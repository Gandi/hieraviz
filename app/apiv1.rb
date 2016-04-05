require 'sinatra/json'
require 'sinatra/cross-origin'

require 'digest/sha1'
require 'dotenv'
require 'yajl'

require 'hieracles'
require 'hieraviz'

require File.expand_path '../common.rb', __FILE__

module HieravizApp
  class ApiV1 < Common
    register Sinatra::CrossOrigin

    configure do
      set :session_secret, settings.configdata['session_seed']
      set :protection, :origin_whitelist => ['http://web.example.com']
      enable :sessions
      enable :cross_origin
      set :allow_origin, :any
      set :allow_methods, [:get, :post, :options]
      set :allow_credentials, true
      set :max_age, "1728000"
      set :expose_headers, ['Content-Type']
    end

    case settings.configdata['auth_method']
    when 'dummy'

      helpers do
        def check_authorization
          logger.info session['access_token']
          if !session['access_token'] && !request.env['HTTP_X_AUTH']
            redirect '/v1/not_logged'
          end
          true
        end
      end

    when 'gitlab', 'http'

      helpers do
        def check_authorization
          if !session['access_token'] && !request.env['HTTP_X_AUTH']
            redirect '/v1/not_logged'
          else
            token = session['access_token'] || request.env['HTTP_X_AUTH']
            session_info = settings.store.get(token, settings.configdata['session_renew'])
            unless session_info['username']
              redirect '/v1/unauthorized'
            end
          end
        end
      end

    end

    helpers do
      def get_facts(base, node)
        Hieraviz::Facts.new(settings.configdata['tmpdir'], base, node, username)
      end
      # def cors_headers()
      #   headers 'Access-Control-Allow-Origin' => '*'
      #   headers 'Access-Control-Allow-Headers' => 'Authorization,Accepts,Content-Type,X-CSRF-Token,X-Requested-With,X-AUTH'
      #   headers 'Access-Control-Allow-Methods' => 'GET,POST,PUT,DELETE,OPTIONS'
      # end
    end

    options '*' do
      response.headers["Allow"] = "HEAD,GET,PUT,POST,DELETE,OPTIONS"
      response.headers["Access-Control-Allow-Headers"] = "X-Requested-With, X-HTTP-Method-Override, Content-Type, Cache-Control, Accept"
      200
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
      hieracles_config = prepare_config(base, node)
      node = Hieracles::Node.new(node, hieracles_config)
      json node.params
    end

    get %r{^/?([-_\.a-zA-Z0-9]+)?/node/([-_\.a-zA-Z0-9]+)/allparams} do |base, node|
      check_authorization
      hieracles_config = prepare_config(base, node)
      node = Hieracles::Node.new(node, hieracles_config)
      json node.params(false)
    end

    get %r{^/?([-_\.a-zA-Z0-9]+)?/node/([-_\.a-zA-Z0-9]+)/facts} do |base, node|
      check_authorization
      facts = get_facts(base, node)
      json facts.read
    end

    post %r{^/?([-_\.a-zA-Z0-9]+)?/node/([-_\.a-zA-Z0-9]+)/facts} do |base, node|
      check_authorization
      facts = get_facts(base, node)
      data = JSON.parse(request.body.read.to_s)
      json facts.write(data)
    end

    delete %r{^/?([-_\.a-zA-Z0-9]+)?/node/([-_\.a-zA-Z0-9]+)/facts} do |base, node|
      check_authorization
      facts = get_facts(base, node)
      json facts.remove
    end

    get %r{^/?([-_\.a-zA-Z0-9]+)?/node/([-_\.a-zA-Z0-9]+)$} do |base, node|
      check_authorization
      hieracles_config = prepare_config(base, node)
      node = Hieracles::Node.new(node, hieracles_config)
      json node.params
    end

    get %r{^/?([-_\.a-zA-Z0-9]+)?/farms} do |base|
      check_authorization
      cross_origin
      hieracles_config = prepare_config(base)
      json Hieracles::Registry.farms_counted(hieracles_config, base)
    end

    get %r{^/?([-_\.a-zA-Z0-9]+)?/vars} do |base|
      check_authorization
      hieracles_config = prepare_config(base)
      hiera = Hieracles::Hiera.new(hieracles_config)
      json hiera.params
    end

    get %r{^/?([-_\.a-zA-Z0-9]+)?/node/([-_\.a-zA-Z0-9]+)/hierarchy} do |base, node|
      check_authorization
      hieracles_config = prepare_config(base, node)
      hiera = Hieracles::Hiera.new(hieracles_config)
      nodeinfo = Hieracles::Node.new(node, hieracles_config)
      facts = get_facts(base, node)
      res = {
        'hiera'    => hiera.hierarchy,
        'vars'     => hiera.params,
        'info'     => nodeinfo.info,
        'files'    => nodeinfo.files,
        'facts'    => facts.read,
        'defaults' => settings.configdata['defaultscope']
      }
      json res
    end

    get %r{^/?([-_\.a-zA-Z0-9]+)?/farm/([-_\.a-zA-Z0-9]+)$} do |base, farm|
      # check_authorization
      cross_origin
      hieracles_config = prepare_config(base)
      nodes =  Hieracles::Registry.nodes_data(hieracles_config, base).each_with_object({}) do |(key, val), acc|
        acc[key] = val if val['farm'] == farm
      end
      params = request.env['rack.request.query_hash']
      if params.count > 0
        puts params
        params.each do |k, v|
          nodes = nodes.keep_if do |key, item|
            item[k] == v
          end
        end
      end
      json nodes
    end

    get '/ppdb/events' do
      check_authorization
      puppetdb = Hieraviz::Puppetdb.new settings.configdata['puppetdb']
      json puppetdb.events
    end

    get '/not_logged' do
      json(error: 'Not connected.')
    end

    get '/unauthorized' do
      json(error: 'Unauthorized')
    end

    not_found do
      json(error: 'Endpoint not found')
    end

  end
end
