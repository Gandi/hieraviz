module Hieraviz
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
      end
    end
    
    def write(data)
      File.open(@filename, 'wb') {|f| f.write(Marshal.dump(data)) }
    end

    def remove
      File.unlink @filename
    end

  end
end
