module Hieraviz
  module Store
    def data
      @_data ||= {}
    end

    def set(key, value)
      File.open(tmpfile(key), 'w') do |f|
        f.print Marshal.dump(value)
      end
      data[key] = value
    end

    def get(key, expiration = false)
      f = tmpfile(key)
      File.unlink(f) if File.exist?(f) && expiration && expired?(f, expiration)
      data[key] ||= Marshal.load(File.read(f).chomp) if File.exist?(f)
    end

    def dump
      data
    end

    def tmpfile(name)
      File.join tmpdir, name.gsub(/[^a-z0-9]/, '')
    end

    def tmpdir
      @_tmpdir ||= init_tmpdir
    end

    def init_tmpdir
      config = Hieraviz::Config.load
      tmp = config['tmpdir'] || '/tmp'
      begin
        FileUtils.mkdir_p(tmp) unless Dir.exist?(tmp)
      rescue
        tmp = '/tmp'
      end
      tmp
    end

    def expired?(file, duration)
      Time.now - duration > File.mtime(file)
    end

    module_function :data, :set, :get, :dump, :tmpfile, :tmpdir, :init_tmpdir, :expired?
  end
end
