# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Hanko::Rails::Configuration do
  subject(:config) { described_class.new }

  describe 'defaults' do
    it { expect(config.cookie_name).to eq('hanko') }
    it { expect(config.jwks_cache_ttl).to eq(3600) }
    it { expect(config.exclude_paths).to eq([]) }
  end

  describe 'setters' do
    it 'accepts all configuration values' do
      config.cookie_name = 'my_session'
      config.jwks_cache_ttl = 600
      config.exclude_paths = ['/healthz']

      expect(config.cookie_name).to eq('my_session')
      expect(config.jwks_cache_ttl).to eq(600)
      expect(config.exclude_paths).to eq(['/healthz'])
    end
  end
end

RSpec.describe Hanko::Rails do
  after { described_class.reset_configuration! }

  describe '.configure' do
    it 'yields a Configuration instance' do
      described_class.configure do |c|
        expect(c).to be_a(Hanko::Rails::Configuration)
      end
    end

    it 'stores configuration globally' do
      described_class.configure do |c|
        c.cookie_name = 'custom'
      end

      expect(described_class.configuration.cookie_name).to eq('custom')
    end
  end

  describe '.reset_configuration!' do
    it 'resets to defaults' do
      described_class.configure { |c| c.cookie_name = 'custom' }
      described_class.reset_configuration!

      expect(described_class.configuration.cookie_name).to eq('hanko')
    end
  end
end
