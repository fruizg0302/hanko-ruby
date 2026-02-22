# frozen_string_literal: true

require 'faraday'
require 'json'
require_relative 'middleware/raise_error'

module Hanko
  # Low-level HTTP wrapper around Faraday.
  #
  # Configures the Faraday connection with authentication headers,
  # timeouts, and the {Middleware::RaiseError} middleware.
  class Connection
    # @return [Faraday::Connection] the underlying Faraday connection
    attr_reader :connection

    # Builds a new Connection from the given configuration.
    #
    # @param config [Configuration] SDK configuration
    # @param adapter [Array, nil] optional Faraday adapter override (for testing)
    # @return [Connection]
    def initialize(config, adapter: nil)
      @connection = build_connection(config, adapter)
    end

    # Performs an HTTP GET request.
    #
    # @param path [String] the request path
    # @param params [Hash] query parameters
    # @return [Faraday::Response]
    def get(path, params = {})
      connection.get(path, params)
    end

    # Performs an HTTP POST request with a JSON body.
    #
    # @param path [String] the request path
    # @param body [Hash] the request body (serialized to JSON)
    # @return [Faraday::Response]
    def post(path, body = {})
      connection.post(path, JSON.generate(body))
    end

    # Performs an HTTP PUT request with a JSON body.
    #
    # @param path [String] the request path
    # @param body [Hash] the request body (serialized to JSON)
    # @return [Faraday::Response]
    def put(path, body = {})
      connection.put(path, JSON.generate(body))
    end

    # Performs an HTTP PATCH request with a JSON body.
    #
    # @param path [String] the request path
    # @param body [Hash] the request body (serialized to JSON)
    # @return [Faraday::Response]
    def patch(path, body = {})
      connection.patch(path, JSON.generate(body))
    end

    # Performs an HTTP DELETE request.
    #
    # @param path [String] the request path
    # @param params [Hash] query parameters
    # @return [Faraday::Response]
    def delete(path, params = {})
      connection.delete(path, params)
    end

    private

    def build_connection(config, adapter)
      Faraday.new(url: config.api_url) do |f|
        f.headers['Content-Type'] = 'application/json'
        f.headers['Accept'] = 'application/json'
        f.headers['Authorization'] = "Bearer #{config.api_key}" if config.api_key

        f.options.timeout = config.timeout
        f.options.open_timeout = config.open_timeout

        f.use Middleware::RaiseError
        f.request :json

        if adapter
          f.adapter(*adapter)
        else
          f.adapter Faraday.default_adapter
        end
      end
    end
  end
end
