# frozen_string_literal: true

RSpec.describe Hanko::Configuration do
  subject(:config) { described_class.new }

  describe 'defaults' do
    it { expect(config.api_url).to be_nil }
    it { expect(config.api_key).to be_nil }
    it { expect(config.timeout).to eq(5) }
    it { expect(config.open_timeout).to eq(2) }
    it { expect(config.retry_count).to eq(1) }
    it { expect(config.clock_skew).to eq(0) }
    it { expect(config.jwks_cache_ttl).to eq(3600) }
    it { expect(config.logger).to be_nil }
    it { expect(config.log_level).to eq(:info) }
  end

  describe 'setters' do
    it 'accepts all configuration values' do
      config.api_url = 'https://hanko.example.com'
      config.api_key = 'secret-key'
      config.timeout = 10

      expect(config.api_url).to eq('https://hanko.example.com')
      expect(config.api_key).to eq('secret-key')
      expect(config.timeout).to eq(10)
    end
  end

  describe '#inspect' do
    it 'redacts api_key' do
      config.api_key = 'super-secret-key-12345'
      expect(config.inspect).not_to include('super-secret-key-12345')
      expect(config.inspect).to include('[REDACTED]')
    end
  end

  describe 'global configuration' do
    after { Hanko.reset_configuration! }

    describe '.configure' do
      it 'yields a Configuration instance' do
        Hanko.configure do |c|
          expect(c).to be_a(described_class)
        end
      end

      it 'stores configuration globally' do
        Hanko.configure do |c|
          c.api_url = 'https://test.hanko.io'
        end

        expect(Hanko.configuration.api_url).to eq('https://test.hanko.io')
      end
    end

    describe '.reset_configuration!' do
      it 'resets to defaults' do
        Hanko.configure { |c| c.api_url = 'https://test.hanko.io' }
        Hanko.reset_configuration!
        expect(Hanko.configuration.api_url).to be_nil
      end
    end
  end
end
