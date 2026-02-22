# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Hanko::TestHelper do
  describe '.generate_test_token' do
    it 'returns a valid JWT string' do
      token = described_class.generate_test_token(sub: 'user-1', exp: Time.now.to_i + 300)

      expect(token).to be_a(String)
      expect(token.split('.')).to have_attributes(length: 3)
    end

    it 'encodes the given claims' do
      exp = Time.now.to_i + 300
      token = described_class.generate_test_token(sub: 'user-1', exp: exp, role: 'admin')

      payload = JWT.decode(token, nil, false).first

      expect(payload['sub']).to eq('user-1')
      expect(payload['exp']).to eq(exp)
      expect(payload['role']).to eq('admin')
    end

    it 'can be verified with the test JWKS' do
      token = described_class.generate_test_token(sub: 'user-1', exp: Time.now.to_i + 300)
      jwks_json = described_class.test_jwks_response
      jwks = JWT::JWK::Set.new(JSON.parse(jwks_json))

      payload, = JWT.decode(token, nil, true, algorithms: ['RS256'], jwks: jwks)

      expect(payload['sub']).to eq('user-1')
    end
  end

  describe '.test_jwks_response' do
    it 'returns a valid JWKS JSON string' do
      response = described_class.test_jwks_response
      parsed = JSON.parse(response)

      expect(parsed).to have_key('keys')
      expect(parsed['keys']).to be_an(Array)
      expect(parsed['keys'].first).to have_key('kty')
      expect(parsed['keys'].first['kty']).to eq('RSA')
    end
  end

  describe '.stub_jwks' do
    it 'stubs the JWKS endpoint for the given api_url' do
      described_class.stub_jwks(api_url: 'https://hanko.example.com')

      response = Faraday.get('https://hanko.example.com/.well-known/jwks.json')
      parsed = JSON.parse(response.body)

      expect(parsed).to have_key('keys')
    end

    it 'allows WebhookVerifier to verify test tokens' do
      described_class.stub_jwks(api_url: 'https://hanko.example.com')
      token = described_class.generate_test_token(sub: 'user-1', exp: Time.now.to_i + 300)

      result = Hanko::WebhookVerifier.verify(
        token,
        jwks_url: 'https://hanko.example.com/.well-known/jwks.json'
      )

      expect(result['sub']).to eq('user-1')
    end
  end

  describe '.stub_session' do
    it 'returns a StubVerifier' do
      verifier = described_class.stub_session(sub: 'user-1', exp: Time.now.to_i + 300)

      expect(verifier).to be_a(Hanko::TestHelper::StubVerifier)
    end

    it 'returns a verifier that responds to #verify with a fixed payload' do
      exp = Time.now.to_i + 300
      verifier = described_class.stub_session(sub: 'user-1', exp: exp, role: 'admin')

      result = verifier.verify('any-token')

      expect(result).to include('sub' => 'user-1', 'exp' => exp, 'role' => 'admin')
    end
  end

  describe Hanko::TestHelper::StubVerifier do
    it 'wraps a payload hash' do
      verifier = described_class.new('sub' => 'user-1', 'exp' => 123)

      expect(verifier.verify('ignored-token')).to eq('sub' => 'user-1', 'exp' => 123)
    end

    it 'returns the same payload regardless of token' do
      verifier = described_class.new('sub' => 'user-1')

      expect(verifier.verify('token-a')).to eq(verifier.verify('token-b'))
    end
  end
end
