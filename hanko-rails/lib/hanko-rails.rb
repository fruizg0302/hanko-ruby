# frozen_string_literal: true

require 'hanko'
require_relative 'hanko/rails/version'
require_relative 'hanko/rails/configuration'
require_relative 'hanko/rails/middleware'
require_relative 'hanko/rails/authentication'
require_relative 'hanko/rails/engine' if defined?(Rails::Engine)

module Hanko
  # Rails integration for Hanko authentication.
  #
  # Provides middleware, controller helpers, and test utilities for
  # authenticating users via Hanko in a Rails application.
  #
  # @example Configure Hanko::Rails in an initializer
  #   Hanko::Rails.configure do |config|
  #     config.cookie_name = 'hanko'
  #     config.jwks_cache_ttl = 3600
  #     config.exclude_paths = ['/health']
  #   end
  module Rails
    class << self
      # Returns the current configuration instance.
      #
      # @return [Hanko::Rails::Configuration] the current configuration
      def configuration
        @configuration ||= Configuration.new
      end

      # Yields the configuration instance for modification.
      #
      # @yield [config] the configuration instance
      # @yieldparam config [Hanko::Rails::Configuration] the configuration to modify
      # @return [void]
      #
      # @example
      #   Hanko::Rails.configure do |config|
      #     config.cookie_name = 'hanko_session'
      #   end
      def configure
        yield(configuration)
      end

      # Resets the configuration to default values.
      #
      # @return [Hanko::Rails::Configuration] the new default configuration
      def reset_configuration!
        @configuration = Configuration.new
      end
    end
  end
end
