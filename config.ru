require 'rubygems'
require 'sinatra'
require File.expand_path '../app/main.rb', __FILE__

run Rack::URLMap.new({
  '/' => Web,
  '/v1' => Api
})
