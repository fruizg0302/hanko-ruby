# frozen_string_literal: true

module Hanko
  # Main entry point for interacting with the Hanko API.
  #
  # A client merges any per-instance options with the global {Configuration},
  # then exposes admin and public API namespaces.
  #
  # @example Create a client with inline options
  #   client = Hanko::Client.new(api_url: "https://example.hanko.io", api_key: "key")
  #   client.admin.users.list
  #
  # @example Create a client using global configuration
  #   Hanko.configure { |c| c.api_url = "https://example.hanko.io" }
  #   client = Hanko::Client.new
  class Client
    # @return [Configuration] the resolved configuration for this client
    attr_reader :config

    # Creates a new Hanko API client.
    #
    # Options override values from the global {Hanko.configuration}.
    #
    # @param options [Hash] configuration overrides
    # @option options [String] :api_url the Hanko API base URL
    # @option options [String] :api_key the API key for admin endpoints
    # @option options [Integer] :timeout request timeout in seconds
    # @option options [Integer] :open_timeout connection open timeout in seconds
    # @option options [Integer] :retry_count number of retries on failure
    # @option options [Array] :adapter Faraday adapter (for testing)
    # @raise [ConfigurationError] if api_url is not set
    def initialize(**options)
      @adapter = options.delete(:adapter)
      @config = build_config(options)
      validate_config!
      @connection = Connection.new(@config, adapter: @adapter)
    end

    # Returns the admin API namespace for managing users, emails, etc.
    #
    # @return [Api::AdminNamespace]
    def admin
      @admin ||= Api::AdminNamespace.new(@connection)
    end

    # Returns the public API namespace for flows, well-known endpoints, etc.
    #
    # @return [Api::PublicNamespace]
    def public
      @public ||= Api::PublicNamespace.new(@connection)
    end

    # Returns a human-readable representation with the API key redacted.
    #
    # @return [String]
    def inspect
      "#<#{self.class} api_url=#{config.api_url.inspect} api_key=[REDACTED]>"
    end

    private

    def build_config(options)
      base = Hanko.configuration
      Configuration.new.tap do |c|
        Configuration::ATTRIBUTES.each do |attr|
          value = options.fetch(attr, base.send(attr))
          c.send(:"#{attr}=", value)
        end
      end
    end

    def validate_config!
      raise ConfigurationError, 'api_url is required' unless config.api_url
    end
  end
end
