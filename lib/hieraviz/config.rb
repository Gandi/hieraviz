module Hieraviz
  module Config
    extend self

    def load
      @_config ||= YAML.load_file(configfile)
    end

    def configfile
      file = ENV['HIERAVIZ_CONFIG_FILE'] || File.join("config", "hieraviz.yml")
      file = File.join(root, file) unless file[0] == '/'
      file
    end

    def root
      File.expand_path('../../../', __FILE__)
    end

  end
end
