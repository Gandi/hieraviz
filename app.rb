require 'sinatra'
require 'better_errors'

require 'hieraviz'

configure do
  set :public_folder, File.expand_path('../public', __FILE__)
  set :views_folder, File.expand_path('../views', __FILE__)
  set :erb, layout: :_layout
end

configure :development do
  use BetterErrors::Middleware
  BetterErrors.application_root = File.expand_path('..', __FILE__)
end

helpers do

end

get '/' do
  erb :home
end

get '/test' do
  { data: Time.new }.to_json
end

not_found do
  erb :not_found
end
