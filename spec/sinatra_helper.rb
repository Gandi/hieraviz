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
