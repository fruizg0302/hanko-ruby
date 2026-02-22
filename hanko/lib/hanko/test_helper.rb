# frozen_string_literal: true

require 'jwt'
require 'openssl'
require 'json'
require 'webmock'

module Hanko
  module TestHelper
    class StubVerifier
      def initialize(payload)
        @payload = payload
      end

      def verify(_token)
        @payload
      end
    end

    class << self
      def generate_test_token(sub:, exp:, **extra_claims)
        payload = { 'sub' => sub, 'exp' => exp }.merge(extra_claims.transform_keys(&:to_s))
        JWT.encode(payload, test_key, 'RS256', kid: test_kid)
      end

      def test_jwks_response
        jwk = JWT::JWK.new(test_key, kid: test_kid)
        { keys: [jwk.export] }.to_json
      end

      def stub_jwks(api_url:)
        WebMock::API.stub_request(:get, "#{api_url}/.well-known/jwks.json")
                    .to_return(status: 200, body: test_jwks_response)
      end

      def stub_session(sub:, exp:, **extra_claims)
        payload = { 'sub' => sub, 'exp' => exp }.merge(extra_claims.transform_keys(&:to_s))
        StubVerifier.new(payload)
      end

      private

      def test_key
        @test_key ||= OpenSSL::PKey::RSA.generate(2048)
      end

      def test_kid
        'hanko-test-kid'
      end
    end
  end
end
