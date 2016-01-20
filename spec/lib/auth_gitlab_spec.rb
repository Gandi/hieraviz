require 'spec_helper'
require 'oauth2_helper'

describe Hieraviz::AuthGitlab do

  let(:oauth2) { Hieraviz::AuthGitlab.new({}) }
  before do
    allow(OAuth2::Client).
      to receive(:new).
      and_return(Oauth2Mock.new)
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
    let(:expected) {
      {
        "somekey" => "somevalue"
      }
    }
    let(:expectedfail) {
      {
        "error" => "message"
      }
    }
    before do
      allow(OAuth2::AccessToken).
        to receive(:new).
        and_return(AccessTokenMock.new)
    end
    context "when there is an error" do
      it { expect(oauth2.get_response(urlfail, token)).to eq expectedfail }
    end
    context "when everything is fine" do
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
  end

  describe '.user_info' do
    let(:token) { '123456' }
    let(:expected) { { "somekey" => "somevalue" } }
    before do
      allow(OAuth2::AccessToken).
        to receive(:new).
        and_return(AccessTokenMock.new)
    end
    it { expect(oauth2.user_info(token)).to eq expected }
  end

end
