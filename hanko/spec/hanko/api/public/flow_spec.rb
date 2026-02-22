# frozen_string_literal: true

RSpec.describe Hanko::Api::Public::Flow do
  subject(:flow) { described_class.new(connection) }

  let(:config) { Hanko::Configuration.new.tap { |c| c.api_url = 'https://test.hanko.io' } }
  let(:stubs) { Faraday::Adapter::Test::Stubs.new }
  let(:connection) { Hanko::Connection.new(config, adapter: [:test, stubs]) }

  after { stubs.verify_stubbed_calls }

  describe '#login' do
    it 'POST /login initializes flow' do
      body = '{"status":"continue","actions":[{"name":"passkey"}]}'
      stubs.post('/login') { [200, {}, body] }

      result = flow.login
      expect(result).to be_a(Hanko::FlowResponse)
      expect(result.status).to eq(:continue)
    end

    it 'POST /login advances flow with action' do
      stubs.post('/login', '{"action":"password","data":{"password":"secret"}}') do
        [200, {}, '{"status":"completed","payload":{"session_token":"jwt","user_id":"u1"}}']
      end

      result = flow.login(action: 'password', data: { password: 'secret' })
      expect(result.completed?).to be(true)
      expect(result.session_token).to eq('jwt')
    end
  end

  describe '#registration' do
    it 'POST /registration' do
      stubs.post('/registration') { [200, {}, '{"status":"continue","actions":[]}'] }
      result = flow.registration
      expect(result).to be_a(Hanko::FlowResponse)
    end
  end

  describe '#profile' do
    it 'POST /profile with session_token' do
      stubs.post('/profile', '{"session_token":"jwt"}') { [200, {}, '{"status":"continue","actions":[]}'] }
      result = flow.profile(session_token: 'jwt')
      expect(result).to be_a(Hanko::FlowResponse)
    end
  end
end
