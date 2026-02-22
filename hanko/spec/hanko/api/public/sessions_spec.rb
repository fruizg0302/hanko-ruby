# frozen_string_literal: true

RSpec.describe Hanko::Api::Public::Sessions do
  subject(:sessions) { described_class.new(connection) }

  let(:config) { Hanko::Configuration.new.tap { |c| c.api_url = 'https://test.hanko.io' } }
  let(:stubs) { Faraday::Adapter::Test::Stubs.new }
  let(:connection) { Hanko::Connection.new(config, adapter: [:test, stubs]) }

  after { stubs.verify_stubbed_calls }

  describe '#validate' do
    it 'GET /sessions/validate' do
      stubs.get('/sessions/validate') { [200, {}, '{"is_valid":true,"user_id":"u1"}'] }
      result = sessions.validate
      expect(result.is_valid).to be(true)
      expect(result.user_id).to eq('u1')
    end
  end

  describe '#validate_token' do
    it 'POST /sessions/validate with token in body' do
      stubs.post('/sessions/validate', '{"session_token":"jwt-token"}') { [200, {}, '{"is_valid":true}'] }
      result = sessions.validate_token('jwt-token')
      expect(result.is_valid).to be(true)
    end
  end
end
