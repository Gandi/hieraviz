module Hieraviz
  class Store

    def initialize
      @data = {}
    end

    def set(key, value)
      @data[key.to_sym] = value
    end

    def get(key)
      @data[key.to_sym]
    end

    def dump
      @data
    end

  end
end
