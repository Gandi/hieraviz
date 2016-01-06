module Hieraviz
  module Store
    extend self

    def data
      @_data ||= Hash.new
    end

    def set(key, value)
      File.open(tmpfile(key), 'w') do |f|
        f.print Marshal::dump(value)
      end
      data[key] = value
    end

    def get(key)
      data[key] ||= Marshal::load(File.read(tmpfile(key)).chomp)
    end

    def dump
      data
    end

    def tmpfile(name)
      File.join tmpdir, name.gsub(/[^a-z0-9]/,'')
    end

    def tmpdir
      @_tmpdir ||= init_tmpdir 
    end

    def init_tmpdir
      configfile = ENV['HIERAVIZ_CONFIG_FILE'] || File.join("config", "hieraviz.yml")
      configfile = File.expand_path(File.join('../../../app', configfile), __FILE__) unless configfile[0] == '/'
      config = YAML.load_file(configfile)
      tmp = config['tmpdir'] || '/tmp'
      begin
        FileUtils.mkdir_p(tmp) unless Dir.exist?(tmp)
      rescue Exception => e
        tmp = '/tmp'
      end
      tmp
    end

  end
end
