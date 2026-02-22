# frozen_string_literal: true

module Hanko
  module Rails
    # Holds configuration options for the Hanko Rails integration.
    #
    # @example
    #   config = Hanko::Rails::Configuration.new
    #   config.cookie_name = 'hanko_session'
    #   config.exclude_paths = ['/health', '/status']
    class Configuration
      # @!attribute [rw] cookie_name
      #   The name of the cookie that holds the Hanko JWT token.
      #   @return [String] the cookie name (default: +'hanko'+)

      # @!attribute [rw] jwks_cache_ttl
      #   Time-to-live in seconds for the cached JWKS key set.
      #   @return [Integer] the cache TTL in seconds (default: +3600+)

      # @!attribute [rw] exclude_paths
      #   Request paths that skip token extraction and verification.
      #   @return [Array<String>] the list of excluded path prefixes (default: +[]+)
      attr_accessor :cookie_name, :jwks_cache_ttl, :exclude_paths

      # Initializes a new Configuration with default values.
      #
      # @return [Configuration] a new instance with default settings
      def initialize
        @cookie_name = 'hanko'
        @jwks_cache_ttl = 3600
        @exclude_paths = []
      end
    end
  end
end
