# frozen_string_literal: true

require 'jwt'
require 'openssl'
require 'json'
require 'webmock'

module Hanko
  # Test utilities for generating JWT tokens and stubbing Hanko endpoints.
  #
  # Provides helpers that make it easy to test Hanko authentication
  # without hitting a real Hanko API.
  #
  # @example Generate a test token and stub JWKS
  #   token = Hanko::TestHelper.generate_test_token(sub: "user-123", exp: Time.now.to_i + 3600)
  #   Hanko::TestHelper.stub_jwks(api_url: "https://example.hanko.io")
  module TestHelper
    # A simple stub that returns a fixed payload instead of verifying a token.
    class StubVerifier
      # @param payload [Hash] the payload to return on verify
      def initialize(payload)
        @payload = payload
      end

      # Returns the fixed payload, ignoring the token.
      #
      # @param _token [String] ignored
      # @return [Hash] the stub payload
      def verify(_token)
        @payload
      end
    end

    class << self
      # Generates a signed JWT test token using an ephemeral RSA key.
      #
      # @param sub [String] the subject claim (user ID)
      # @param exp [Integer] the expiration time as a Unix timestamp
      # @param extra_claims [Hash] additional claims to include in the payload
      # @return [String] the encoded JWT token
      #
      # @example
      #   token = Hanko::TestHelper.generate_test_token(sub: "user-123", exp: Time.now.to_i + 3600)
      def generate_test_token(sub:, exp:, **extra_claims)
        payload = { 'sub' => sub, 'exp' => exp }.merge(extra_claims.transform_keys(&:to_s))
        JWT.encode(payload, test_key, 'RS256', kid: test_kid)
      end

      # Returns a JSON string containing the test JWKS (public key set).
      #
      # @return [String] JSON-encoded JWKS response body
      def test_jwks_response
        jwk = JWT::JWK.new(test_key, kid: test_kid)
        { keys: [jwk.export] }.to_json
      end

      # Stubs the JWKS endpoint using WebMock so tokens from {generate_test_token} can be verified.
      #
      # @param api_url [String] the Hanko API base URL
      # @return [WebMock::RequestStub] the WebMock stub
      #
      # @example
      #   Hanko::TestHelper.stub_jwks(api_url: "https://example.hanko.io")
      def stub_jwks(api_url:)
        WebMock::API.stub_request(:get, "#{api_url}/.well-known/jwks.json")
                    .to_return(status: 200, body: test_jwks_response)
      end

      # Creates a StubVerifier that returns a fixed session payload without cryptographic verification.
      #
      # @param sub [String] the subject claim (user ID)
      # @param exp [Integer] the expiration time as a Unix timestamp
      # @param extra_claims [Hash] additional claims to include in the payload
      # @return [StubVerifier] a verifier that returns the given payload
      #
      # @example
      #   verifier = Hanko::TestHelper.stub_session(sub: "user-123", exp: Time.now.to_i + 3600)
      #   verifier.verify("any-token") #=> {"sub" => "user-123", "exp" => ...}
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
