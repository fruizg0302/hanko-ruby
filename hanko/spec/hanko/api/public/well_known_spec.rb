# frozen_string_literal: true

RSpec.describe Hanko::Api::Public::WellKnown do
  let(:config) { Hanko::Configuration.new.tap { |c| c.api_url = "https://test.hanko.io" } }
  let(:stubs) { Faraday::Adapter::Test::Stubs.new }
  let(:connection) { Hanko::Connection.new(config, adapter: [:test, stubs]) }

  subject(:well_known) { described_class.new(connection) }

  after { stubs.verify_stubbed_calls }

  describe "#jwks" do
    it "GET /.well-known/jwks.json" do
      jwks_body = '{"keys":[{"kty":"RSA","kid":"k1","n":"abc","e":"AQAB"}]}'
      stubs.get("/.well-known/jwks.json") { [200, {}, jwks_body] }

      result = well_known.jwks
      expect(result).to be_a(Hanko::Resource)
      expect(result.keys).to be_an(Array)
    end
  end

  describe "#config" do
    it "GET /.well-known/config" do
      config_body = '{"password":{"enabled":true},"passkey":{"enabled":true}}'
      stubs.get("/.well-known/config") { [200, {}, config_body] }

      result = well_known.config
      expect(result.password).to be_a(Hanko::Resource)
      expect(result.password.enabled).to be(true)
    end
  end
end
