# frozen_string_literal: true

module Hanko
  # Holds configuration options for the Hanko SDK.
  #
  # Set values via {Hanko.configure} or pass them directly to {Hanko::Client#initialize}.
  #
  # @example
  #   Hanko.configure do |c|
  #     c.api_url  = "https://example.hanko.io"
  #     c.api_key  = "your-api-key"
  #     c.timeout  = 10
  #   end
  class Configuration
    ATTRIBUTES = %i[
      api_url api_key timeout open_timeout retry_count
      clock_skew jwks_cache_ttl logger log_level
    ].freeze

    # @!attribute [rw] api_url
    #   @return [String, nil] the Hanko API base URL
    # @!attribute [rw] api_key
    #   @return [String, nil] the API key for admin endpoints
    # @!attribute [rw] timeout
    #   @return [Integer] request timeout in seconds (default: 5)
    # @!attribute [rw] open_timeout
    #   @return [Integer] connection open timeout in seconds (default: 2)
    # @!attribute [rw] retry_count
    #   @return [Integer] number of automatic retries (default: 1)
    # @!attribute [rw] clock_skew
    #   @return [Integer] allowed clock skew in seconds for token validation (default: 0)
    # @!attribute [rw] jwks_cache_ttl
    #   @return [Integer] JWKS cache time-to-live in seconds (default: 3600)
    # @!attribute [rw] logger
    #   @return [Logger, nil] optional logger instance
    # @!attribute [rw] log_level
    #   @return [Symbol] log level (default: :info)
    attr_accessor(*ATTRIBUTES)

    # Creates a new Configuration with sensible defaults.
    #
    # @return [Configuration]
    def initialize
      @timeout = 5
      @open_timeout = 2
      @retry_count = 1
      @clock_skew = 0
      @jwks_cache_ttl = 3600
      @log_level = :info
    end

    # Returns a human-readable representation with the API key redacted.
    #
    # @return [String]
    def inspect
      attrs = ATTRIBUTES.map do |key|
        value = send(key)
        value = '[REDACTED]' if key == :api_key && value
        "#{key}=#{value.inspect}"
      end
      "#<#{self.class} #{attrs.join(', ')}>"
    end
  end
end
