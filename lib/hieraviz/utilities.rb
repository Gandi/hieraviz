module Hieraviz
  # Convenience methods used by various other classes
  module Utilities
    
    def redirect_uri(url)
      uri = URI.parse(url)
      uri.path = '/logged-in'
      uri.query = nil
      uri.fragment = nil
      uri.to_s
    end

  end
end
