# frozen_string_literal: true

require 'jwt'
require 'faraday'
require 'json'

module Hanko
  class WebhookVerifier
    ALGORITHM = 'RS256'

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
