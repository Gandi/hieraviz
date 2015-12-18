require 'yajl'
require 'sinatra'
require 'sinatra/config_file'
require 'sinatra/namespace'
require 'sinatra/json'
require 'better_errors'
require 'dotenv'

require 'hieraviz'

Dotenv.load

configure do
  set :public_folder, Proc.new { File.join(root, "public") }
  set :views_folder, Proc.new { File.join(root, "views") }
  set :erb, layout: :_layout
  set :app_name, 'bleh'
  set :hieracles_configfile, ENV['HIERAVIZ_CONFIG_FILE'] || File.join(settings.root, "config", "hieraviz.yml")
end

configure :development do
  use BetterErrors::Middleware
  BetterErrors.application_root = File.expand_path('..', __FILE__)
end

config_file settings.hieracles_configfile

helpers do

end

get '/' do
  erb :home
end

not_found do
  erb :not_found
end

namespace '/v1' do
  get '/test' do
    json data: Time.new 
  end

end
