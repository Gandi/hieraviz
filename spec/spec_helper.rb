$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'hieraviz'

require 'rack/test'
require 'rspec'

ENV['RACK_ENV'] = 'test'
ENV['HIERAVIZ_CONFIG_FILE'] = File.expand_path '../files/config.yml', __FILE__

if !ENV['BUILD']
  require 'rubygems'
  require 'bundler'

  if ENV['COV']
    require 'simplecov'
    SimpleCov.start do
      add_group 'bin', 'bin'
      add_group 'app', 'app'
      add_group 'lib', 'lib'
      add_filter 'vendor'
      add_filter 'spec'
    end
  else
    require 'coveralls'
    Coveralls.wear!
  end
end

RSpec.configure do |config| 
  config.mock_with :rspec
  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end
