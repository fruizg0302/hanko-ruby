# frozen_string_literal: true

RSpec.describe Hanko::Api::BaseResource do
  subject(:resource) { described_class.new(connection, '/test') }

  let(:config) { Hanko::Configuration.new.tap { |c| c.api_url = 'https://test.hanko.io' } }
  let(:stubs) { Faraday::Adapter::Test::Stubs.new }
  let(:connection) { Hanko::Connection.new(config, adapter: [:test, stubs]) }

  after { stubs.verify_stubbed_calls }

  describe '#list' do
    it 'sends GET and returns array of Resources' do
      stubs.get('/test') { [200, {}, '[{"id":"1"},{"id":"2"}]'] }
      result = resource.list
      expect(result).to all(be_a(Hanko::Resource))
      expect(result.map(&:id)).to eq(%w[1 2])
    end
  end

  describe '#get' do
    it 'sends GET with id and returns a Resource' do
      stubs.get('/test/abc-123') { [200, {}, '{"id":"abc-123","email":"a@b.com"}'] }
      result = resource.get('abc-123')
      expect(result).to be_a(Hanko::Resource)
      expect(result.id).to eq('abc-123')
    end
  end

  describe '#create' do
    it 'sends POST with body and returns a Resource' do
      stubs.post('/test', '{"email":"a@b.com"}') { [201, {}, '{"id":"new-1","email":"a@b.com"}'] }
      result = resource.create(email: 'a@b.com')
      expect(result).to be_a(Hanko::Resource)
      expect(result.id).to eq('new-1')
    end
  end

  describe '#update' do
    it 'sends PUT with id and body' do
      stubs.put('/test/abc-123', '{"email":"new@b.com"}') { [200, {}, '{"id":"abc-123","email":"new@b.com"}'] }
      result = resource.update('abc-123', email: 'new@b.com')
      expect(result).to be_a(Hanko::Resource)
    end
  end

  describe '#delete' do
    it 'sends DELETE with id' do
      stubs.delete('/test/abc-123') { [204, {}, ''] }
      expect { resource.delete('abc-123') }.not_to raise_error
    end
  end
end
