# frozen_string_literal: true

RSpec.describe Hanko::Api::Admin::AuditLogs do
  let(:config) { Hanko::Configuration.new.tap { |c| c.api_url = "https://test.hanko.io"; c.api_key = "key" } }
  let(:stubs) { Faraday::Adapter::Test::Stubs.new }
  let(:connection) { Hanko::Connection.new(config, adapter: [:test, stubs]) }

  subject(:audit_logs) { described_class.new(connection) }

  after { stubs.verify_stubbed_calls }

  it "GET /audit_logs" do
    stubs.get("/audit_logs") { [200, {}, '[{"id":"al1","action":"user.created"}]'] }
    result = audit_logs.list
    expect(result.first.action).to eq("user.created")
  end
end
