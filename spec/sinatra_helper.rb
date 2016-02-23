ENV['HIERAVIZ_CONFIG_FILE'] = File.expand_path '../files/config.yml', __FILE__

require 'spec_helper'

require File.expand_path '../../app/main.rb', __FILE__

require 'sinatra/base'

module RSpecMixin
  include Rack::Test::Methods
  def app
    described_class
  end
end

RSpec.configure do |config|
  config.include RSpecMixin
end
