# frozen_string_literal: true

RSpec.describe Hanko::Api::Admin::Sessions do
  let(:config) { Hanko::Configuration.new.tap { |c| c.api_url = "https://test.hanko.io"; c.api_key = "key" } }
  let(:stubs) { Faraday::Adapter::Test::Stubs.new }
  let(:connection) { Hanko::Connection.new(config, adapter: [:test, stubs]) }

  subject(:sessions) { described_class.new(connection, "/users/u1") }

  after { stubs.verify_stubbed_calls }

  it "GET /users/:id/sessions" do
    stubs.get("/users/u1/sessions") { [200, {}, '[{"id":"s1"}]'] }
    expect(sessions.list.first.id).to eq("s1")
  end

  it "DELETE /users/:id/sessions/:session_id" do
    stubs.delete("/users/u1/sessions/s1") { [204, {}, ""] }
    expect(sessions.delete("s1")).to be(true)
  end
end
