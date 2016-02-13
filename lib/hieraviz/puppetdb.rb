module Hieraviz
  class Puppetdb

    def initialize(config)
      @request = Hieracles::Puppetdb::Request.new config
    end

    def events
      @request.events
    end

  end
end
