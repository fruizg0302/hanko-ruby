# frozen_string_literal: true

module Hanko
  # Base error class for all Hanko SDK errors.
  class Error < StandardError; end

  # Raised when the SDK configuration is invalid or incomplete.
  class ConfigurationError < Error; end

  # Raised when a JWT token cannot be decoded or has an invalid signature.
  class InvalidTokenError < Error; end

  # Raised when a JWT token has expired.
  class ExpiredTokenError < Error; end

  # Raised when JWKS fetching or parsing fails.
  class JwksError < Error; end

  # Raised when a network-level connection error occurs.
  class ConnectionError < Error; end

  # Raised when the Hanko API returns an HTTP 4xx or 5xx response.
  class ApiError < Error
    # @return [Integer, nil] the HTTP status code
    attr_reader :status

    # @return [Hash, nil] the parsed response body
    attr_reader :body

    # @param message [String, nil] the error message
    # @param status [Integer, nil] the HTTP status code
    # @param body [Hash, nil] the parsed response body
    def initialize(message = nil, status: nil, body: nil)
      @status = status
      @body = body
      super(message)
    end
  end

  # Raised when the API returns HTTP 401 Unauthorized.
  class AuthenticationError < ApiError; end

  # Raised when the API returns HTTP 404 Not Found.
  class NotFoundError < ApiError; end

  # Raised when the API returns HTTP 429 Too Many Requests.
  class RateLimitError < ApiError
    # @return [Integer, nil] seconds to wait before retrying
    attr_reader :retry_after

    # @param message [String, nil] the error message
    # @param status [Integer, nil] the HTTP status code
    # @param body [Hash, nil] the parsed response body
    # @param retry_after [Integer, nil] seconds to wait before retrying
    def initialize(message = nil, status: nil, body: nil, retry_after: nil)
      @retry_after = retry_after
      super(message, status: status, body: body)
    end
  end
end
