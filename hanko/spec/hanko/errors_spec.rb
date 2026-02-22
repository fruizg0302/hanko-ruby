# frozen_string_literal: true

RSpec.describe Hanko::Error do
  it "inherits from StandardError" do
    expect(Hanko::Error.new).to be_a(StandardError)
  end

  it "stores a message" do
    error = Hanko::Error.new("something went wrong")
    expect(error.message).to eq("something went wrong")
  end
end

RSpec.describe Hanko::ApiError do
  it "inherits from Hanko::Error" do
    expect(Hanko::ApiError.new).to be_a(Hanko::Error)
  end

  it "stores status and body" do
    error = Hanko::ApiError.new("bad request", status: 400, body: { error: "invalid" })
    expect(error.status).to eq(400)
    expect(error.body).to eq({ error: "invalid" })
    expect(error.message).to eq("bad request")
  end
end

RSpec.describe Hanko::AuthenticationError do
  it("inherits from ApiError") { expect(Hanko::AuthenticationError.new).to be_a(Hanko::ApiError) }
end

RSpec.describe Hanko::NotFoundError do
  it("inherits from ApiError") { expect(Hanko::NotFoundError.new).to be_a(Hanko::ApiError) }
end

RSpec.describe Hanko::RateLimitError do
  it "exposes retry_after" do
    error = Hanko::RateLimitError.new("slow down", status: 429, body: nil, retry_after: 30)
    expect(error.retry_after).to eq(30)
  end
end

RSpec.describe Hanko::ConfigurationError do
  it("inherits from Hanko::Error") { expect(Hanko::ConfigurationError.new).to be_a(Hanko::Error) }
end

RSpec.describe Hanko::InvalidTokenError do
  it("inherits from Hanko::Error") { expect(Hanko::InvalidTokenError.new).to be_a(Hanko::Error) }
end

RSpec.describe Hanko::ExpiredTokenError do
  it("inherits from Hanko::Error") { expect(Hanko::ExpiredTokenError.new).to be_a(Hanko::Error) }
end

RSpec.describe Hanko::JwksError do
  it("inherits from Hanko::Error") { expect(Hanko::JwksError.new).to be_a(Hanko::Error) }
end

RSpec.describe Hanko::ConnectionError do
  it("inherits from Hanko::Error") { expect(Hanko::ConnectionError.new).to be_a(Hanko::Error) }
end
