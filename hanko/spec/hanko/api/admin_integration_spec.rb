# frozen_string_literal: true

RSpec.describe "Admin API integration" do
  let(:stubs) { Faraday::Adapter::Test::Stubs.new }
  let(:client) do
    Hanko::Client.new(api_url: "https://test.hanko.io", api_key: "key", adapter: [:test, stubs])
  end

  after { stubs.verify_stubbed_calls }

  it "client.admin.users.list" do
    stubs.get("/users") { [200, {}, '[{"id":"u1"}]'] }
    expect(client.admin.users.list.first.id).to eq("u1")
  end

  it "client.admin.users('u1').emails.list" do
    stubs.get("/users/u1/emails") { [200, {}, '[{"id":"e1"}]'] }
    expect(client.admin.users("u1").emails.list.first.id).to eq("e1")
  end

  it "client.admin.users('u1').metadata.get" do
    stubs.get("/users/u1/metadata") { [200, {}, '{"role":"admin"}'] }
    expect(client.admin.users("u1").metadata.get.role).to eq("admin")
  end

  it "client.admin.webhooks.list" do
    stubs.get("/webhooks") { [200, {}, '[{"id":"wh1"}]'] }
    expect(client.admin.webhooks.list.first.id).to eq("wh1")
  end

  it "client.admin.audit_logs.list" do
    stubs.get("/audit_logs") { [200, {}, '[{"id":"al1"}]'] }
    expect(client.admin.audit_logs.list.first.id).to eq("al1")
  end
end
