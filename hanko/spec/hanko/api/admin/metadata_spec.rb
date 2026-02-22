# frozen_string_literal: true

RSpec.describe Hanko::Api::Admin::Metadata do
  subject(:metadata) { described_class.new(connection, '/users/u1') }

  let(:config) do
    Hanko::Configuration.new.tap do |c|
      c.api_url = 'https://test.hanko.io'
      c.api_key = 'key'
    end
  end
  let(:stubs) { Faraday::Adapter::Test::Stubs.new }
  let(:connection) { Hanko::Connection.new(config, adapter: [:test, stubs]) }

  after { stubs.verify_stubbed_calls }

  it 'GET /users/:id/metadata' do
    stubs.get('/users/u1/metadata') { [200, {}, '{"role":"admin","plan":"pro"}'] }
    result = metadata.get
    expect(result.role).to eq('admin')
  end

  it 'PATCH /users/:id/metadata (deep merge)' do
    stubs.patch('/users/u1/metadata', '{"plan":"enterprise"}') { [200, {}, '{"role":"admin","plan":"enterprise"}'] }
    result = metadata.update(plan: 'enterprise')
    expect(result.plan).to eq('enterprise')
  end
end
