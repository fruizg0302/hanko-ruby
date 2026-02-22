# frozen_string_literal: true

RSpec.describe Hanko::Api::Admin::Users do
  subject(:users) { described_class.new(connection) }

  let(:config) do
    Hanko::Configuration.new.tap do |c|
      c.api_url = 'https://test.hanko.io'
      c.api_key = 'key'
    end
  end
  let(:stubs) { Faraday::Adapter::Test::Stubs.new }
  let(:connection) { Hanko::Connection.new(config, adapter: [:test, stubs]) }

  after { stubs.verify_stubbed_calls }

  describe '#list' do
    it 'GET /users' do
      stubs.get('/users') { [200, {}, '[{"id":"u1","email":"a@b.com"}]'] }
      result = users.list
      expect(result.first.id).to eq('u1')
    end
  end

  describe '#get' do
    it 'GET /users/:id' do
      stubs.get('/users/u1') { [200, {}, '{"id":"u1"}'] }
      expect(users.get('u1').id).to eq('u1')
    end
  end

  describe '#create' do
    it 'POST /users' do
      stubs.post('/users', '{"email":"a@b.com"}') { [201, {}, '{"id":"u1","email":"a@b.com"}'] }
      result = users.create(email: 'a@b.com')
      expect(result.email).to eq('a@b.com')
    end
  end

  describe '#delete' do
    it 'DELETE /users/:id' do
      stubs.delete('/users/u1') { [204, {}, ''] }
      expect { users.delete('u1') }.not_to raise_error
    end
  end

  describe 'nested resource access via #call' do
    it 'returns a UserContext for nested access' do
      context = users.call('u1')
      expect(context).to be_a(Hanko::Api::Admin::Users::UserContext)
    end
  end
end
