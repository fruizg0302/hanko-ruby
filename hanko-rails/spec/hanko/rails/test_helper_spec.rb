# frozen_string_literal: true

require 'spec_helper'
require 'rack/test'
require 'webmock/rspec'

RSpec.describe Hanko::Rails::TestHelper do
  include Rack::Test::Methods

  let(:inner_app) do
    lambda { |env|
      [200, { 'content-type' => 'application/json' }, [{ session: env['hanko.session'] }.to_json]]
    }
  end

  let(:app) { Hanko::Rails::Middleware.new(inner_app) }

  before do
    Hanko.configure { |c| c.api_url = 'https://hanko.example.com' }
    Hanko::Rails.reset_configuration!
  end

  after do
    Hanko.reset_configuration!
    Hanko::Rails.reset_configuration!
  end

  describe '#sign_in_as_hanko_user' do
    it 'sets the hanko cookie with a valid JWT' do
      extend described_class

      sign_in_as_hanko_user('user-1')

      get '/'

      body = JSON.parse(last_response.body)
      expect(body['session']).to include('sub' => 'user-1')
    end

    it 'respects custom cookie name' do
      Hanko::Rails.configure { |c| c.cookie_name = 'my_session' }
      extend described_class

      sign_in_as_hanko_user('user-2')

      get '/'

      body = JSON.parse(last_response.body)
      expect(body['session']).to include('sub' => 'user-2')
    end
  end

  describe '#sign_out_hanko_user' do
    it 'clears the hanko cookie' do
      extend described_class

      sign_in_as_hanko_user('user-1')
      sign_out_hanko_user

      get '/'

      body = JSON.parse(last_response.body)
      expect(body['session']).to be_nil
    end
  end
end
