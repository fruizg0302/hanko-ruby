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

  describe 'Hanko::Rails.configure' do
    after { Hanko::Rails.reset_configuration! }

    it 'yields a Configuration instance' do
      Hanko::Rails.configure do |c|
        expect(c).to be_a(described_class)
      end
    end

    it 'stores configuration globally' do
      Hanko::Rails.configure do |c|
        c.cookie_name = 'custom'
      end

      expect(Hanko::Rails.configuration.cookie_name).to eq('custom')
    end
  end

  describe 'Hanko::Rails.reset_configuration!' do
    after { Hanko::Rails.reset_configuration! }

    it 'resets to defaults' do
      Hanko::Rails.configure { |c| c.cookie_name = 'custom' }
      Hanko::Rails.reset_configuration!

      expect(Hanko::Rails.configuration.cookie_name).to eq('hanko')
    end
  end
end
