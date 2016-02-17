module Hieraviz
  class Facts

    def initialize(tmpdir)
      @tmpdir = tmpdir
    end
    
    def read(base, node, user)
      filename = File.join(@tmpdir, "#{base}__#{name}__#{user}")
      Marshall.load(filename)
    end
    
    def write(base, node, user, data)
      filename = File.join(@tmpdir, "#{base}__#{name}__#{user}")
      Marshal.dump(filename, data)
    end

  end
end
