# frozen_string_literal: true

require_relative 'hanko/version'
require_relative 'hanko/errors'
require_relative 'hanko/resource'
require_relative 'hanko/flow_response'
require_relative 'hanko/configuration'
require_relative 'hanko/middleware/raise_error'
require_relative 'hanko/connection'
require_relative 'hanko/api/base_resource'
require_relative 'hanko/api/admin'
require_relative 'hanko/api/public'
require_relative 'hanko/client'
require_relative 'hanko/webhook_verifier'

# Top-level module for the Hanko Ruby SDK.
#
# Provides authentication and user management via the Hanko API.
# Use {.configure} to set global defaults shared across all {Client} instances.
#
# @example Configure global defaults
#   Hanko.configure do |c|
#     c.api_url  = "https://example.hanko.io"
#     c.api_key  = "your-api-key"
#     c.timeout  = 10
#   end
#
# @example Create a client using global configuration
#   client = Hanko::Client.new
module Hanko
  class << self
    # Returns the global configuration instance.
    #
    # @return [Configuration] the current global configuration
    def configuration
      @configuration ||= Configuration.new
    end

    # Yields the global configuration for modification.
    #
    # @yield [config] the global {Configuration} instance
    # @yieldparam config [Configuration]
    # @return [void]
    #
    # @example
    #   Hanko.configure do |c|
    #     c.api_url = "https://example.hanko.io"
    #     c.api_key = "your-api-key"
    #   end
    def configure
      yield(configuration)
    end

    # Resets the global configuration to defaults.
    #
    # @return [void]
    def reset_configuration!
      @configuration = Configuration.new
    end
  end
end
