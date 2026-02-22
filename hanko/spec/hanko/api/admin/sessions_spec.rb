# frozen_string_literal: true

RSpec.describe Hanko::Api::Admin::Sessions do
  subject(:sessions) { described_class.new(connection, '/users/u1') }

  let(:config) do
    Hanko::Configuration.new.tap do |c|
      c.api_url = 'https://test.hanko.io'
      c.api_key = 'key'
    end
  end
  let(:stubs) { Faraday::Adapter::Test::Stubs.new }
  let(:connection) { Hanko::Connection.new(config, adapter: [:test, stubs]) }

  after { stubs.verify_stubbed_calls }

  it 'GET /users/:id/sessions' do
    stubs.get('/users/u1/sessions') { [200, {}, '[{"id":"s1"}]'] }
    expect(sessions.list.first.id).to eq('s1')
  end

  it 'DELETE /users/:id/sessions/:session_id' do
    stubs.delete('/users/u1/sessions/s1') { [204, {}, ''] }
    expect { sessions.delete('s1') }.not_to raise_error
  end
end
