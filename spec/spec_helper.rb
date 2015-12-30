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
    SimpleCov.profiles.define :app do
      add_group 'bin', '/bin'
      add_group 'app', '/app'
      add_group 'lib', '/lib'
      add_filter '/vendor/'
      add_filter '/spec/'
    end
    SimpleCov.start :app
  else
    require 'coveralls'
    Coveralls.wear!
    # require "codeclimate-test-reporter"
    # CodeClimate::TestReporter.start
  end
end

require File.expand_path '../../app/main.rb', __FILE__

module RSpecMixin
  include Rack::Test::Methods
  def app() described_class end
end

RSpec.configure do |config| 
  config.include RSpecMixin
  config.mock_with :rspec
  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end
