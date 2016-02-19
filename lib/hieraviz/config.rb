module Hieraviz
  module Config
    extend self

    def load
      @_config = YAML.load_file(configfile)
    end

    def configfile
      root_path(ENV['HIERAVIZ_CONFIG_FILE'] || File.join("config", "hieraviz.yml"))
    end

    def basepaths
      if @_config && @_config['basepath_dir']
        Dir.glob(root_path(@_config['basepath_dir'])).map { |p| File.expand_path(p) }
      end
    end

    def root
      File.expand_path('../../../', __FILE__)
    end

    def root_path(path)
      if path[0] == '/'
        path
      else
        File.join(root, path)
      end
    end

  end
end
