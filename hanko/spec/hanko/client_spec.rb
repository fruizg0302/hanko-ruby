# frozen_string_literal: true

RSpec.describe Hanko::Client do
  after { Hanko.reset_configuration! }

  describe 'initialization' do
    it 'uses global configuration by default' do
      Hanko.configure { |c| c.api_url = 'https://global.hanko.io' }
      client = described_class.new
      expect(client.config.api_url).to eq('https://global.hanko.io')
    end

    it 'accepts per-client overrides' do
      client = described_class.new(api_url: 'https://custom.hanko.io', api_key: 'key-123')
      expect(client.config.api_url).to eq('https://custom.hanko.io')
      expect(client.config.api_key).to eq('key-123')
    end

    it 'raises ConfigurationError when api_url is missing' do
      expect { described_class.new }.to raise_error(Hanko::ConfigurationError, /api_url/)
    end
  end

  describe '#inspect' do
    it 'redacts api_key' do
      client = described_class.new(api_url: 'https://test.hanko.io', api_key: 'secret')
      expect(client.inspect).not_to include('secret')
    end
  end
end
