class AuthCodeMock
  def authorize_url(_args)
    'authorize url'
  end

  def get_token(_code, _args)
    '123456'
  end
end

class RequestMock
  def body
    '{"somekey":"somevalue"}'
  end

  def url
    'http://example.com'
  end
end

class AccessTokenMock
  def get(url)
    raise "\n{\"message\":\"message\"}" if url == 'fail'
    RequestMock.new
  end
end

class Oauth2Mock
  attr_reader :auth_code
  def initialize(*_args)
    @auth_code = AuthCodeMock.new
  end
end
