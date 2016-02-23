$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)

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

require 'rack/test'
require 'rspec'

ENV['RACK_ENV'] = 'test'
# ENV['HIERAVIZ_CONFIG_FILE'] = File.expand_path '../files/config.yml', __FILE__

require 'hieraviz'

RSpec.configure do |config| 
  config.mock_with :rspec
  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end

module Rack
  module Test
    class Session
      alias_method :old_env_for, :env_for
      def rack_session
        @rack_session ||= {}
      end
      def rack_session=(hash)
        @rack_session = hash
      end
      def env_for(path, env)
        old_env_for(path, env).merge({'rack.session' => rack_session})
      end
    end
  end
end
