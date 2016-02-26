module Hieraviz
  # module to manage parsing and holding of configuration variables
  module Config
    def load
      @_config = YAML.load_file(configfile)
    end

    def configfile
      root_path(ENV['HIERAVIZ_CONFIG_FILE'] || File.join('config', 'hieraviz.yml'))
    end

    def basepaths
      basepath_dir = @_config['basepath_dir']
      if @_config && basepath_dir
        Dir.glob(root_path(basepath_dir)).map { |path| File.expand_path(path) }
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
    
    module_function :load, :configfile, :basepaths, :root, :root_path
  end
end
