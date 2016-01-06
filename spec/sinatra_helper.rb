require File.expand_path '../../app/main.rb', __FILE__

module RSpecMixin
  include Rack::Test::Methods
  def app() described_class end
end

RSpec.configure do |config| 
  config.include RSpecMixin
end
