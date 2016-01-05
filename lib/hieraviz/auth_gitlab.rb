require 'oauth2'

module Hieraviz
  class AuthGitlab

    def initialize(settings, session)
      @@client ||= OAuth2::Client.new(
        settings.configdata['oauth2_auth']['application_id'], 
        settings.configdata['oauth2_auth']['secret'], 
        :site => settings.configdata['oauth2_auth']['host']
        )
      @session = session
    end


    def get_response(url)
      access_token = OAuth2::AccessToken.new(@@client, @session['access_token'])
      begin
        JSON.parse(access_token.get(url).body)
      rescue Exception => e
        { 'error' => JSON.parse(e.message.split(/\n/)[1])['message'] }
      end
    end


    def redirect_uri
      uri = URI.parse(request.url)
      uri.path = '/logged-in'
      uri.query = nil
      uri.to_s
    end

    def login_url
      @@client.auth_code.authorize_url(:redirect_uri => redirect_uri)
    end

  end
end
