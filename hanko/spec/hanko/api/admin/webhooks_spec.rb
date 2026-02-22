# frozen_string_literal: true

RSpec.describe Hanko::Api::Admin::Webhooks do
  subject(:webhooks) { described_class.new(connection) }

  let(:config) do
    Hanko::Configuration.new.tap do |c|
      c.api_url = 'https://test.hanko.io'
      c.api_key = 'key'
    end
  end
  let(:stubs) { Faraday::Adapter::Test::Stubs.new }
  let(:connection) { Hanko::Connection.new(config, adapter: [:test, stubs]) }

  after { stubs.verify_stubbed_calls }

  it 'GET /webhooks' do
    stubs.get('/webhooks') { [200, {}, '[{"id":"wh1","callback":"https://example.com/hook"}]'] }
    expect(webhooks.list.first.callback).to eq('https://example.com/hook')
  end

  it 'GET /webhooks/:id' do
    stubs.get('/webhooks/wh1') { [200, {}, '{"id":"wh1"}'] }
    expect(webhooks.get('wh1').id).to eq('wh1')
  end

  it 'POST /webhooks' do
    body = '{"callback":"https://example.com/hook","events":["email.send"]}'
    stubs.post('/webhooks', body) { [201, {}, '{"id":"wh1"}'] }
    result = webhooks.create(callback: 'https://example.com/hook', events: ['email.send'])
    expect(result.id).to eq('wh1')
  end

  it 'PUT /webhooks/:id' do
    stubs.put('/webhooks/wh1', '{"events":["email.send","user.create"]}') { [200, {}, '{"id":"wh1"}'] }
    result = webhooks.update('wh1', events: ['email.send', 'user.create'])
    expect(result.id).to eq('wh1')
  end

  it 'DELETE /webhooks/:id' do
    stubs.delete('/webhooks/wh1') { [204, {}, ''] }
    expect { webhooks.delete('wh1') }.not_to raise_error
  end
end
