require 'spec_helper'
require 'oauth2_helper'

describe Hieraviz::AuthGitlab do
  let(:settings) do
    {
      'application_id' => '',
      'secret' => '',
      'host' => '',
      'resource_required' => false,
      'required_response_key' => '',
      'required_response_value' => ''
    }
  end
  let(:oauth2) { Hieraviz::AuthGitlab.new(settings) }
  before do
    allow(OAuth2::Client)
      .to receive(:new)
      .and_return(Oauth2Mock.new)
  end

  describe '.new' do
    it { expect(oauth2).to be_a Hieraviz::AuthGitlab }
  end

  describe '.access_token' do
    it { expect(oauth2.access_token(RequestMock.new, 'code')).to eq '123456' }
  end

  describe '.get_response' do
    let(:url) { 'http://example.com/something' }
    let(:token) { '123456' }
    let(:urlfail) { 'fail' }
    let(:expected) do
      {
        'somekey' => 'somevalue'
      }
    end
    let(:expectedfail) do
      {
        'error' => 'message'
      }
    end
    before do
      allow(OAuth2::AccessToken)
        .to receive(:new)
        .and_return(AccessTokenMock.new)
    end
    context 'when there is an error' do
      it { expect(oauth2.get_response(urlfail, token)).to eq expectedfail }
    end
    context 'when everything is fine' do
      it { expect(oauth2.get_response(url, token)).to eq expected }
    end
  end

  describe '.redirect_uri' do
    let(:url) { 'http://example.com/something?var=value#hash' }
    let(:expected) { 'http://example.com/logged-in' }
    it { expect(oauth2.redirect_uri(url)).to eq expected }
  end

  describe '.login_url' do
    it { expect(oauth2.login_url(RequestMock.new)).to eq 'authorize url' }
  end

  describe '.authorized?' do
    context 'when authorization is required' do
      let(:settings) do
        {
          'application_id' => '',
          'secret' => '',
          'host' => '',
          'resource_required' => 'http://example.com/something',
          'required_response_key' => 'id',
          'required_response_value' => '42'
        }
      end
      context 'with a valid authorization' do
        let(:token) { '123456' }
        before do
          allow(OAuth2::AccessToken)
            .to receive(:new)
            .and_return(AccessTokenMock.new)
        end
        it { expect(oauth2.authorized? token).to eq true }
      end
      context 'without a valid authorization' do
        let(:settings) do
          {
            'application_id' => '',
            'secret' => '',
            'host' => '',
            'resource_required' => 'fail',
            'required_response_key' => 'id',
            'required_response_value' => '42'
          }
        end
        let(:token) { '123456' }
        before do
          allow(OAuth2::AccessToken)
            .to receive(:new)
            .and_return(AccessTokenMock.new)
        end
        it { expect(oauth2.authorized? token).to eq false }
      end
    end
    context 'when no authorization is required' do
      let(:token) { '123456' }
      it { expect(oauth2.authorized? token).to be_truthy }
    end
  end

  describe '.user_info' do
    let(:token) { '123456' }
    let(:expected) { { 'somekey' => 'somevalue' } }
    before do
      allow(OAuth2::AccessToken)
        .to receive(:new)
        .and_return(AccessTokenMock.new)
    end
    it { expect(oauth2.user_info(token)).to eq expected }
  end
end
