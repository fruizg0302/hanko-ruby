# frozen_string_literal: true

RSpec.describe Hanko::Api::Admin::Passwords do
  subject(:passwords) { described_class.new(connection, '/users/u1') }

  let(:config) do
    Hanko::Configuration.new.tap do |c|
      c.api_url = 'https://test.hanko.io'
      c.api_key = 'key'
    end
  end
  let(:stubs) { Faraday::Adapter::Test::Stubs.new }
  let(:connection) { Hanko::Connection.new(config, adapter: [:test, stubs]) }

  after { stubs.verify_stubbed_calls }

  it 'POST /users/:id/password' do
    stubs.post('/users/u1/password', '{"password":"secret123"}') { [201, {}, '{"id":"p1"}'] }
    expect(passwords.create(password: 'secret123').id).to eq('p1')
  end

  it 'GET /users/:id/password' do
    stubs.get('/users/u1/password') { [200, {}, '{"id":"p1"}'] }
    expect(passwords.get.id).to eq('p1')
  end

  it 'PUT /users/:id/password' do
    stubs.put('/users/u1/password', '{"password":"newpass"}') { [200, {}, '{"id":"p1"}'] }
    expect(passwords.update(password: 'newpass').id).to eq('p1')
  end

  it 'DELETE /users/:id/password' do
    stubs.delete('/users/u1/password') { [204, {}, ''] }
    expect { passwords.delete }.not_to raise_error
  end
end
