require 'oauth2'

module Hieraviz
  class AuthGitlab

    def initialize(settings)
      @@client ||= OAuth2::Client.new(
        settings['application_id'], 
        settings['secret'], 
        :site => settings['host']
        )
      @settings = settings
    end

    def access_token(request, code)
      @@client.auth_code.get_token(code, :redirect_uri => redirect_uri(request))
    end

    def get_response(url, token)
      access_token = OAuth2::AccessToken.new(@@client, token)
      begin
        JSON.parse(access_token.get(url).body)
      rescue Exception => e
        { 'error' => JSON.parse(e.message.split(/\n/)[1])['message'] }
      end
    end


    def redirect_uri(request)
      uri = URI.parse(request.url)
      uri.path = '/logged-in'
      uri.query = nil
      uri.to_s
    end

    def login_url(request)
      @@client.auth_code.authorize_url(:redirect_uri => redirect_uri(request))
    end

    def authorized?(token)
      if @settings['resource_required']
        resp = get_response(@settings['resource_required'], token)
        if resp['error'] ||
           (resp[@settings['required_response_key']] &&
           resp[@settings['required_response_key']] != resp[@settings['required_response_value']])
          false
        else
          true
        end
      end
      true
    end

    def user_info(token)
      get_response('/api/v3/user', token)
    end

  end
end
