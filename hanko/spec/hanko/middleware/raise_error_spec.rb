# frozen_string_literal: true

require "faraday"

RSpec.describe Hanko::Middleware::RaiseError do
  let(:stubs) { Faraday::Adapter::Test::Stubs.new }
  let(:conn) do
    Faraday.new do |f|
      f.use Hanko::Middleware::RaiseError
      f.adapter :test, stubs
    end
  end

  after { stubs.verify_stubbed_calls }

  it "passes through 2xx responses" do
    stubs.get("/ok") { [200, {}, '{"status":"ok"}'] }
    response = conn.get("/ok")
    expect(response.status).to eq(200)
  end

  it "raises AuthenticationError on 401" do
    stubs.get("/auth") { [401, {}, '{"message":"unauthorized"}'] }
    expect { conn.get("/auth") }.to raise_error(Hanko::AuthenticationError) do |e|
      expect(e.status).to eq(401)
    end
  end

  it "raises NotFoundError on 404" do
    stubs.get("/missing") { [404, {}, ""] }
    expect { conn.get("/missing") }.to raise_error(Hanko::NotFoundError)
  end

  it "raises RateLimitError on 429 with retry_after" do
    stubs.get("/slow") { [429, { "Retry-After" => "30" }, ""] }
    expect { conn.get("/slow") }.to raise_error(Hanko::RateLimitError) do |e|
      expect(e.retry_after).to eq(30)
    end
  end

  it "raises ApiError on other 4xx" do
    stubs.get("/bad") { [422, {}, '{"error":"invalid"}'] }
    expect { conn.get("/bad") }.to raise_error(Hanko::ApiError) do |e|
      expect(e.status).to eq(422)
    end
  end

  it "raises ApiError on 5xx" do
    stubs.get("/fail") { [500, {}, '{"error":"internal"}'] }
    expect { conn.get("/fail") }.to raise_error(Hanko::ApiError) do |e|
      expect(e.status).to eq(500)
    end
  end
end
