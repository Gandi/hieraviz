$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'hieraviz'

require 'rack/test'
require 'rspec'

ENV['RACK_ENV'] = 'test'
ENV['HIERAVIZ_CONFIG_FILE'] = File.expand_path '../files/config.yml', __FILE__

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
