require 'rubygems'
require 'sinatra'

require File.expand_path '../app/main.rb', __FILE__

run Rack::URLMap.new('/' => HieravizApp::Web,
                     '/v1' => HieravizApp::ApiV1)
