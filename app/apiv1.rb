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

    case settings.configdata['auth_method']
    when 'dummy'
      helpers do
        def check_authorization
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
            session_info = Hieraviz::Store.get(token, settings.configdata['session_renew'])
            if !session_info
              redirect '/v1/unauthorized'
            end
          end
        end
      end
    end

    helpers do

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
      facts = Hieraviz::Facts.new(settings.configdata['tmpdir'], base, node, get_username)
      json facts.read
    end

    post %r{^/?([-_\.a-zA-Z0-9]+)?/node/([-_\.a-zA-Z0-9]+)/facts} do |base, node|
      check_authorization
      facts = Hieraviz::Facts.new(settings.configdata['tmpdir'], base, node, get_username)
      data = JSON.parse(request.body.read.to_s)
      json facts.write(data)
    end

    delete %r{^/?([-_\.a-zA-Z0-9]+)?/node/([-_\.a-zA-Z0-9]+)/facts} do |base, node|
      check_authorization
      facts = Hieraviz::Facts.new(settings.configdata['tmpdir'], base, node, get_username)
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
      facts = Hieraviz::Facts.new(settings.configdata['tmpdir'], base, node, get_username)
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
      check_authorization
      hieracles_config = prepare_config(base)
      nodes =  Hieracles::Registry.nodes_data(hieracles_config, base).reduce({}) do |a, (k, v)|
        a[k] = v if v['farm'] == farm
        a
      end
      json nodes
    end

    get '/ppdb/events' do
      check_authorization
      puppetdb = Hieraviz::Puppetdb.new settings.configdata['puppetdb']
      json puppetdb.events
    end

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
