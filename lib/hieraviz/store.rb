module Hieraviz
  class Store

    def initialize(storedir)
      @tmpdir = init_tmpdir(storedir)
    end

    def data
      @_data ||= {}
    end

    def clear_data
      @_data = {}
      data
    end

    def set(key, value)
      File.open(tmpfile(key), 'w') do |file|
        file.print Marshal.dump(value)
      end
      data[key] = value
    end

    def get(key, expiration)
      file = tmpfile(key)
      if File.exist?(file)
        if expiration && expired?(file, expiration)
          File.unlink(file)
          clear_data
        else
          data[key] ||= Marshal.load(File.read(file).chomp)
        end
      else
        clear_data
      end
    end

    def dump
      data
    end

    def tmpfile(name)
      File.join @tmpdir, name.gsub(/[^a-z0-9]/, '')
    end

    def init_tmpdir(storedir)
      tmp = storedir || '/tmp'
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

  end
end
