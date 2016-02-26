module Hieraviz
  # class for storage and retrieval of customized facts that can overlay hiera facts
  class Facts

    def initialize(tmpdir, base, node, user)
      @filename = File.join(tmpdir, "#{base}__#{node}__#{user}")
    end

    def exist?
      File.exist? @filename
    end

    def read
      if exist?
        Marshal.load(File.binread(@filename))
      else
        {}
      end
    end

    def write(data)
      File.open(@filename, 'wb') { |file| file.write(Marshal.dump(data)) }
    end

    def remove
      File.unlink @filename
    end

  end
end
