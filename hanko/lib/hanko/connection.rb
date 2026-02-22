# frozen_string_literal: true

require "faraday"
require "json"
require_relative "middleware/raise_error"

module Hanko
  class Connection
    attr_reader :connection

    def initialize(config, adapter: nil)
      @connection = build_connection(config, adapter)
    end

    def get(path, params = {})
      connection.get(path, params)
    end

    def post(path, body = {})
      connection.post(path, JSON.generate(body))
    end

    def put(path, body = {})
      connection.put(path, JSON.generate(body))
    end

    def patch(path, body = {})
      connection.patch(path, JSON.generate(body))
    end

    def delete(path, params = {})
      connection.delete(path, params)
    end

    private

    def build_connection(config, adapter)
      Faraday.new(url: config.api_url) do |f|
        f.headers["Content-Type"] = "application/json"
        f.headers["Accept"] = "application/json"
        f.headers["Authorization"] = "Bearer #{config.api_key}" if config.api_key

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
