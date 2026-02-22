# frozen_string_literal: true

RSpec.describe Hanko::Connection do
  let(:config) { Hanko::Configuration.new.tap { |c| c.api_url = "https://test.hanko.io" } }

  describe "#connection" do
    it "returns a Faraday::Connection" do
      conn = described_class.new(config)
      expect(conn.connection).to be_a(Faraday::Connection)
    end

    it "sets the base URL from config" do
      conn = described_class.new(config)
      expect(conn.connection.url_prefix.to_s).to eq("https://test.hanko.io/")
    end

    it "includes JSON content-type header" do
      conn = described_class.new(config)
      expect(conn.connection.headers["Content-Type"]).to eq("application/json")
    end

    it "includes the error-raising middleware" do
      conn = described_class.new(config)
      handlers = conn.connection.builder.handlers
      expect(handlers).to include(Hanko::Middleware::RaiseError)
    end
  end

  describe "#connection with api_key" do
    it "includes Authorization header when api_key is set" do
      config.api_key = "test-key"
      conn = described_class.new(config)
      expect(conn.connection.headers["Authorization"]).to eq("Bearer test-key")
    end

    it "omits Authorization header when api_key is nil" do
      conn = described_class.new(config)
      expect(conn.connection.headers).not_to have_key("Authorization")
    end
  end

  describe "HTTP methods" do
    let(:stubs) { Faraday::Adapter::Test::Stubs.new }
    let(:conn) { described_class.new(config, adapter: [:test, stubs]) }

    after { stubs.verify_stubbed_calls }

    it "#get sends GET request" do
      stubs.get("/users") { [200, {}, '[]'] }
      response = conn.get("/users")
      expect(response.status).to eq(200)
    end

    it "#post sends POST with JSON body" do
      stubs.post("/users", '{"email":"a@b.com"}') { [201, {}, '{"id":"1"}'] }
      response = conn.post("/users", email: "a@b.com")
      expect(response.status).to eq(201)
    end

    it "#put sends PUT with JSON body" do
      stubs.put("/users/1", '{"email":"new@b.com"}') { [200, {}, '{"id":"1"}'] }
      response = conn.put("/users/1", email: "new@b.com")
      expect(response.status).to eq(200)
    end

    it "#patch sends PATCH with JSON body" do
      stubs.patch("/users/1", '{"email":"new@b.com"}') { [200, {}, '{"id":"1"}'] }
      response = conn.patch("/users/1", email: "new@b.com")
      expect(response.status).to eq(200)
    end

    it "#delete sends DELETE request" do
      stubs.delete("/users/1") { [204, {}, ""] }
      response = conn.delete("/users/1")
      expect(response.status).to eq(204)
    end
  end
end
