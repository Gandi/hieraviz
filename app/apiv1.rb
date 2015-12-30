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
      json Hieracles::Registry.nodes(settings.config)
    end

    get '/node/:n/info' do |node|
      node = Hieracles::Node.new(node, settings.config)
      json node.info
    end

    get '/node/:n/params' do |node|
      node = Hieracles::Node.new(node, settings.config)
      json node.params
    end

    get '/node/:n/allparams' do |node|
      node = Hieracles::Node.new(node, settings.config)
      json node.params(false)
    end

    get '/node/:n' do |node|
      node = Hieracles::Node.new(node, settings.config)
      json node.params
    end

    get '/farms' do
      json Hieracles::Registry.farms(settings.config)
    end

    get '/farm/:n' do |farm|
      req = Hieracles::Puppetdb::Request.new(settings.configdata['puppetdb'])
      farm_nodes = req.facts('farm', farm)
      json farm_nodes.data
    end

    not_found do
      json({ error: "data not found" })
    end

  end
end
