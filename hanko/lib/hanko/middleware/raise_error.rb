# frozen_string_literal: true

require "faraday"
require "json"

module Hanko
  module Middleware
    class RaiseError < Faraday::Middleware
      def on_complete(env)
        return if env.status < 400

        body = parse_body(env.body)
        message = body["message"] || body["error"] || "HTTP #{env.status}"

        raise error_for(env.status, message, body, env.response_headers)
      end

      private

      def error_for(status, message, body, headers)
        case status
        when 401
          AuthenticationError.new(message, status: status, body: body)
        when 404
          NotFoundError.new(message, status: status, body: body)
        when 429
          retry_after = headers["Retry-After"]&.to_i
          RateLimitError.new(message, status: status, body: body, retry_after: retry_after)
        else
          ApiError.new(message, status: status, body: body)
        end
      end

      def parse_body(body)
        return {} if body.nil? || body.empty?

        JSON.parse(body)
      rescue JSON::ParserError
        {}
      end
    end
  end
end
