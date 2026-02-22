# frozen_string_literal: true

RSpec.describe Hanko::Api::Admin::Emails do
  let(:config) { Hanko::Configuration.new.tap { |c| c.api_url = "https://test.hanko.io"; c.api_key = "key" } }
  let(:stubs) { Faraday::Adapter::Test::Stubs.new }
  let(:connection) { Hanko::Connection.new(config, adapter: [:test, stubs]) }
  let(:user_base) { "/users/u1" }

  subject(:emails) { described_class.new(connection, user_base) }

  after { stubs.verify_stubbed_calls }

  it "GET /users/:id/emails" do
    stubs.get("/users/u1/emails") { [200, {}, '[{"id":"e1","address":"a@b.com"}]'] }
    result = emails.list
    expect(result.first.address).to eq("a@b.com")
  end

  it "GET /users/:id/emails/:email_id" do
    stubs.get("/users/u1/emails/e1") { [200, {}, '{"id":"e1"}'] }
    expect(emails.get("e1").id).to eq("e1")
  end

  it "POST /users/:id/emails" do
    stubs.post("/users/u1/emails", '{"address":"new@b.com"}') { [201, {}, '{"id":"e2","address":"new@b.com"}'] }
    result = emails.create(address: "new@b.com")
    expect(result.address).to eq("new@b.com")
  end

  it "DELETE /users/:id/emails/:email_id" do
    stubs.delete("/users/u1/emails/e1") { [204, {}, ""] }
    expect(emails.delete("e1")).to be(true)
  end

  it "POST /users/:id/emails/:email_id/set_primary" do
    stubs.post("/users/u1/emails/e1/set_primary") { [200, {}, '{"id":"e1","is_primary":true}'] }
    result = emails.set_primary("e1")
    expect(result.is_primary).to be(true)
  end
end
