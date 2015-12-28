require 'sinatra/json'

require 'digest/sha1'
require 'dotenv'
require 'yajl'

require 'hieracles'
require 'hieraviz'

require File.expand_path '../common.rb', __FILE__

module HieravizApp
  class ApiV1 < Common

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
end
