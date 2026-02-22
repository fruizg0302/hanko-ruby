# frozen_string_literal: true

require 'spec_helper'
require 'openssl'

RSpec.describe Hanko::WebhookVerifier do
  let(:rsa_key) { OpenSSL::PKey::RSA.generate(2048) }
  let(:kid) { 'test-kid-123' }
  let(:jwks_url) { 'https://hanko.example.com/.well-known/jwks.json' }

  let(:jwks_response) do
    jwk = JWT::JWK.new(rsa_key, kid: kid)
    { keys: [jwk.export] }.to_json
  end

  def encode_token(payload, key: rsa_key, algorithm: 'RS256', headers: {})
    JWT.encode(payload, key, algorithm, { kid: kid }.merge(headers))
  end

  before do
    stub_request(:get, jwks_url).to_return(status: 200, body: jwks_response)
  end

  describe '.verify' do
    context 'with a valid token' do
      it 'returns the decoded payload' do
        token = encode_token({ 'sub' => 'user-1', 'exp' => Time.now.to_i + 300 })

        result = described_class.verify(token, jwks_url: jwks_url)

        expect(result).to include('sub' => 'user-1')
      end
    end

    context 'with an expired token' do
      it 'raises ExpiredTokenError' do
        token = encode_token({ 'sub' => 'user-1', 'exp' => Time.now.to_i - 300 })

        expect do
          described_class.verify(token, jwks_url: jwks_url)
        end.to raise_error(Hanko::ExpiredTokenError)
      end
    end

    context 'with an invalid signature' do
      it 'raises InvalidTokenError' do
        other_key = OpenSSL::PKey::RSA.generate(2048)
        token = encode_token({ 'sub' => 'user-1', 'exp' => Time.now.to_i + 300 }, key: other_key)

        expect do
          described_class.verify(token, jwks_url: jwks_url)
        end.to raise_error(Hanko::InvalidTokenError)
      end
    end

    context 'with a non-RS256 algorithm' do
      it 'raises InvalidTokenError' do
        hmac_token = JWT.encode({ 'sub' => 'user-1', 'exp' => Time.now.to_i + 300 }, 'secret', 'HS256')

        expect do
          described_class.verify(hmac_token, jwks_url: jwks_url)
        end.to raise_error(Hanko::InvalidTokenError)
      end
    end

    context 'when JWKS endpoint is unavailable' do
      before do
        stub_request(:get, jwks_url).to_return(status: 500, body: 'Internal Server Error')
      end

      it 'raises InvalidTokenError' do
        token = encode_token({ 'sub' => 'user-1', 'exp' => Time.now.to_i + 300 })

        expect do
          described_class.verify(token, jwks_url: jwks_url)
        end.to raise_error(Hanko::InvalidTokenError)
      end
    end

    context 'when JWKS endpoint returns invalid JSON' do
      before do
        stub_request(:get, jwks_url).to_return(status: 200, body: 'not json')
      end

      it 'raises InvalidTokenError' do
        token = encode_token({ 'sub' => 'user-1', 'exp' => Time.now.to_i + 300 })

        expect do
          described_class.verify(token, jwks_url: jwks_url)
        end.to raise_error(Hanko::InvalidTokenError)
      end
    end
  end
end
