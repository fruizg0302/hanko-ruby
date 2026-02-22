# frozen_string_literal: true

RSpec.describe Hanko::Api::Admin::WebauthnCredentials do
  let(:config) { Hanko::Configuration.new.tap { |c| c.api_url = "https://test.hanko.io"; c.api_key = "key" } }
  let(:stubs) { Faraday::Adapter::Test::Stubs.new }
  let(:connection) { Hanko::Connection.new(config, adapter: [:test, stubs]) }

  subject(:creds) { described_class.new(connection, "/users/u1") }

  after { stubs.verify_stubbed_calls }

  it "GET /users/:id/webauthn_credentials" do
    stubs.get("/users/u1/webauthn_credentials") { [200, {}, '[{"id":"wc1"}]'] }
    expect(creds.list.first.id).to eq("wc1")
  end

  it "GET /users/:id/webauthn_credentials/:credential_id" do
    stubs.get("/users/u1/webauthn_credentials/wc1") { [200, {}, '{"id":"wc1"}'] }
    expect(creds.get("wc1").id).to eq("wc1")
  end

  it "DELETE /users/:id/webauthn_credentials/:credential_id" do
    stubs.delete("/users/u1/webauthn_credentials/wc1") { [204, {}, ""] }
    expect(creds.delete("wc1")).to be(true)
  end
end
