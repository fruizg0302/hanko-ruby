# frozen_string_literal: true

module Hanko
  class Error < StandardError; end

  class ConfigurationError < Error; end
  class InvalidTokenError < Error; end
  class ExpiredTokenError < Error; end
  class JwksError < Error; end
  class ConnectionError < Error; end

  class ApiError < Error
    attr_reader :status, :body

    def initialize(message = nil, status: nil, body: nil)
      @status = status
      @body = body
      super(message)
    end
  end

  class AuthenticationError < ApiError; end
  class NotFoundError < ApiError; end

  class RateLimitError < ApiError
    attr_reader :retry_after

    def initialize(message = nil, status: nil, body: nil, retry_after: nil)
      @retry_after = retry_after
      super(message, status: status, body: body)
    end
  end
end
