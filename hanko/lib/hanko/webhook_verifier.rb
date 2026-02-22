# frozen_string_literal: true

require 'jwt'
require 'faraday'
require 'json'

module Hanko
  # Verifies Hanko webhook JWT tokens against a remote JWKS endpoint.
  #
  # @example Verify a webhook token
  #   payload = Hanko::WebhookVerifier.verify(token, jwks_url: "https://example.hanko.io/.well-known/jwks.json")
  #   puts payload["sub"]
  class WebhookVerifier
    ALGORITHM = 'RS256'

    # Decodes and verifies a JWT token using keys from the given JWKS URL.
    #
    # @param token [String] the JWT token to verify
    # @param jwks_url [String] URL of the JWKS endpoint
    # @return [Hash] the decoded JWT payload
    # @raise [ExpiredTokenError] if the token has expired
    # @raise [InvalidTokenError] if the token is invalid or cannot be decoded
    def self.verify(token, jwks_url:)
      jwks = fetch_jwks(jwks_url)
      decoded = JWT.decode(token, nil, true, algorithms: [ALGORITHM], jwks: jwks)
      decoded.first
    rescue JWT::ExpiredSignature => e
      raise ExpiredTokenError, e.message
    rescue JWT::DecodeError => e
      raise InvalidTokenError, e.message
    end

    def self.fetch_jwks(url)
      response = Faraday.get(url)
      jwks_data = JSON.parse(response.body)
      JWT::JWK::Set.new(jwks_data)
    rescue JSON::ParserError, Faraday::Error => e
      raise InvalidTokenError, "Failed to fetch JWKS: #{e.message}"
    end

    private_class_method :fetch_jwks
  end
end
