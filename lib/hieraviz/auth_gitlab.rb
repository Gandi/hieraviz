require 'oauth2'

module Hieraviz
  class AuthGitlab

    def initialize(settings)
      @client = OAuth2::Client.new(
        settings['application_id'],
        settings['secret'],
        site: settings['host']
      )
      @settings = settings
    end

    def access_token(request, code)
      @client.auth_code.get_token(code, redirect_uri: redirect_uri(request.url))
    end

    def get_response(url, token)
      a_token = OAuth2::AccessToken.new(@client, token)
      begin
        JSON.parse(a_token.get(url).body)
      rescue StandardError => e
        { 'error' => JSON.parse(e.message.split(/\n/)[1])['message'] }
      end
    end

    def redirect_uri(url)
      uri = URI.parse(url)
      uri.path = '/logged-in'
      uri.query = nil
      uri.fragment = nil
      uri.to_s
    end

    def login_url(request)
      @client.auth_code.authorize_url(redirect_uri: redirect_uri(request.url))
    end

    def authorized?(token)
      resource_required = @settings['resource_required']
      if resource_required
        resp = get_response(resource_required, token)
        resp_required_response_key = resp[@settings['required_response_key']]
        resp_required_response_value = resp[@settings['required_response_value']]
        if resp['error'] ||
           (resp_required_response_key &&
           resp_required_response_key != resp_required_response_value)
          return false
        end
      end
      true
    end

    def user_info(token)
      get_response('/api/v3/user', token)
    end

  end
end
