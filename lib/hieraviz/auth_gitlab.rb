require 'oauth2'
require 'hieraviz/utilities'

module Hieraviz
  # class to manage gitlab oauth2 connection and authorization checks
  class AuthGitlab
    include Utilities

    def initialize(settings)
      @settings = settings
      @client = OAuth2::Client.new(
        @settings['application_id'],
        @settings['secret'],
        site: @settings['host']
      )
    end

    def access_token(request, code)
      @client.auth_code.get_token(code, redirect_uri: redirect_uri(request.url))
    end

    def get_response(url, token)
      a_token = OAuth2::AccessToken.new(@client, token)
      begin
        JSON.parse(a_token.get(url).body)
      rescue StandardError => error
        { 'error' => JSON.parse(error.message.split(/\n/)[1])['message'] }
      end
    end

    def login_url(request)
      @client.auth_code.authorize_url(redirect_uri: redirect_uri(request.url))
    end

    def authorized?(token)
      resource_required = @settings['resource_required']
      if resource_required
        return check_authorization(resource_required, token)
      end
      true
    end

    def check_authorization(resource_required, token)
      resp = get_response(resource_required, token)
      resp_required_response_key = resp[@settings['required_response_key']].to_s
      resp_required_response_value = @settings['required_response_value'].to_s
      if resp['error'] || 
        ( resp_required_response_key && 
          resp_required_response_key != resp_required_response_value)
        return false
      end
      true
    end

    def user_info(token)
      get_response('/api/v3/user', token)
    end

  end
end
