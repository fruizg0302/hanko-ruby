# frozen_string_literal: true

require 'spec_helper'
require 'rack/test'
require 'webmock/rspec'

RSpec.describe Hanko::Rails::Middleware do
  include Rack::Test::Methods

  let(:inner_app) do
    lambda { |env|
      [200, { 'content-type' => 'application/json' }, [{ session: env['hanko.session'] }.to_json]]
    }
  end

  let(:app) { described_class.new(inner_app) }

  before do
    Hanko.configure { |c| c.api_url = 'https://hanko.example.com' }
    Hanko::Rails.reset_configuration!
    Hanko::TestHelper.stub_jwks(api_url: 'https://hanko.example.com')
  end

  after do
    Hanko.reset_configuration!
    Hanko::Rails.reset_configuration!
  end

  describe 'with a valid session cookie' do
    it 'sets env["hanko.session"] with decoded payload' do
      token = Hanko::TestHelper.generate_test_token(sub: 'user-1', exp: Time.now.to_i + 300)
      set_cookie "hanko=#{token}"

      get '/'

      body = JSON.parse(last_response.body)
      expect(body['session']).to include('sub' => 'user-1')
    end
  end

  describe 'with a valid Bearer token' do
    it 'sets env["hanko.session"] from Authorization header' do
      token = Hanko::TestHelper.generate_test_token(sub: 'user-2', exp: Time.now.to_i + 300)

      get '/', {}, { 'HTTP_AUTHORIZATION' => "Bearer #{token}" }

      body = JSON.parse(last_response.body)
      expect(body['session']).to include('sub' => 'user-2')
    end
  end

  describe 'with no token' do
    it 'sets env["hanko.session"] to nil' do
      get '/'

      body = JSON.parse(last_response.body)
      expect(body['session']).to be_nil
    end
  end

  describe 'with an invalid token' do
    it 'sets env["hanko.session"] to nil and does not block' do
      set_cookie 'hanko=invalid.jwt.token'

      get '/'

      expect(last_response.status).to eq(200)
      body = JSON.parse(last_response.body)
      expect(body['session']).to be_nil
    end
  end

  describe 'with an expired token' do
    it 'sets env["hanko.session"] to nil' do
      token = Hanko::TestHelper.generate_test_token(sub: 'user-1', exp: Time.now.to_i - 300)
      set_cookie "hanko=#{token}"

      get '/'

      body = JSON.parse(last_response.body)
      expect(body['session']).to be_nil
    end
  end

  describe 'excluded paths' do
    before do
      Hanko::Rails.configure { |c| c.exclude_paths = ['/healthz'] }
    end

    it 'skips token extraction for excluded paths' do
      token = Hanko::TestHelper.generate_test_token(sub: 'user-1', exp: Time.now.to_i + 300)
      set_cookie "hanko=#{token}"

      get '/healthz'

      body = JSON.parse(last_response.body)
      expect(body['session']).to be_nil
    end
  end

  describe 'custom cookie name' do
    before do
      Hanko::Rails.configure { |c| c.cookie_name = 'my_session' }
    end

    it 'reads from the configured cookie name' do
      token = Hanko::TestHelper.generate_test_token(sub: 'user-1', exp: Time.now.to_i + 300)
      set_cookie "my_session=#{token}"

      get '/'

      body = JSON.parse(last_response.body)
      expect(body['session']).to include('sub' => 'user-1')
    end
  end

  describe 'cookie takes precedence over header' do
    it 'uses cookie when both are present' do
      cookie_token = Hanko::TestHelper.generate_test_token(sub: 'cookie-user', exp: Time.now.to_i + 300)
      header_token = Hanko::TestHelper.generate_test_token(sub: 'header-user', exp: Time.now.to_i + 300)
      set_cookie "hanko=#{cookie_token}"

      get '/', {}, { 'HTTP_AUTHORIZATION' => "Bearer #{header_token}" }

      body = JSON.parse(last_response.body)
      expect(body['session']).to include('sub' => 'cookie-user')
    end
  end
end
