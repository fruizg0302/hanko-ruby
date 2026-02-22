# frozen_string_literal: true

RSpec.describe Hanko::Error do
  it 'inherits from StandardError' do
    expect(described_class.new).to be_a(StandardError)
  end

  it 'stores a message' do
    error = described_class.new('something went wrong')
    expect(error.message).to eq('something went wrong')
  end

  describe Hanko::ApiError do
    it 'inherits from Hanko::Error' do
      expect(described_class.new).to be_a(Hanko::Error)
    end

    it 'stores status and body' do
      error = described_class.new('bad request', status: 400, body: { error: 'invalid' })
      expect(error.status).to eq(400)
      expect(error.body).to eq({ error: 'invalid' })
      expect(error.message).to eq('bad request')
    end
  end

  describe Hanko::AuthenticationError do
    it('inherits from ApiError') { expect(described_class.new).to be_a(Hanko::ApiError) }
  end

  describe Hanko::NotFoundError do
    it('inherits from ApiError') { expect(described_class.new).to be_a(Hanko::ApiError) }
  end

  describe Hanko::RateLimitError do
    it 'exposes retry_after' do
      error = described_class.new('slow down', status: 429, body: nil, retry_after: 30)
      expect(error.retry_after).to eq(30)
    end
  end

  describe Hanko::ConfigurationError do
    it('inherits from Hanko::Error') { expect(described_class.new).to be_a(Hanko::Error) }
  end

  describe Hanko::InvalidTokenError do
    it('inherits from Hanko::Error') { expect(described_class.new).to be_a(Hanko::Error) }
  end

  describe Hanko::ExpiredTokenError do
    it('inherits from Hanko::Error') { expect(described_class.new).to be_a(Hanko::Error) }
  end

  describe Hanko::JwksError do
    it('inherits from Hanko::Error') { expect(described_class.new).to be_a(Hanko::Error) }
  end

  describe Hanko::ConnectionError do
    it('inherits from Hanko::Error') { expect(described_class.new).to be_a(Hanko::Error) }
  end
end
