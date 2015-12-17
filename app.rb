require 'sinatra'
require 'better_errors'

require 'hieraviz'

configure do
  set :public_folder, File.expand_path('../public', __FILE__)
  set :views_folder, File.expand_path('../views', __FILE__)
end

configure :development do
  use BetterErrors::Middleware
  BetterErrors.application_root = File.expand_path('..', __FILE__)
end

get '/' do
  erb :home, layout: :template
end
