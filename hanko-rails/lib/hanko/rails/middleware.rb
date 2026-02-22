# frozen_string_literal: true

module Hanko
  module Rails
    # Rack middleware that extracts a Hanko JWT from the request cookie or
    # +Authorization: Bearer+ header, verifies it against the Hanko JWKS
    # endpoint, and stores the decoded session payload in +env['hanko.session']+.
    #
    # Paths listed in {Configuration#exclude_paths} are skipped entirely.
    class Middleware
      # Initializes the middleware with the next Rack application.
      #
      # @param app [#call] the next Rack application in the middleware stack
      # @return [Middleware] a new middleware instance
      def initialize(app)
        @app = app
      end

      # Processes an incoming request, extracts and verifies the Hanko token,
      # and forwards the request to the next middleware.
      #
      # @param env [Hash] the Rack environment hash
      # @return [Array<(Integer, Hash, #each)>] the Rack response triplet
      def call(env)
        request = Rack::Request.new(env)

        unless excluded_path?(request.path)
          token = extract_token(request)
          env['hanko.session'] = verify_token(token) if token
        end

        @app.call(env)
      end

      private

      def extract_token(request)
        cookie_token(request) || bearer_token(request)
      end

      def cookie_token(request)
        request.cookies[Hanko::Rails.configuration.cookie_name]
      end

      def bearer_token(request)
        header = request.env['HTTP_AUTHORIZATION']
        header&.match(/\ABearer (.+)\z/)&.[](1)
      end

      def verify_token(token)
        Hanko::WebhookVerifier.verify(token, jwks_url: jwks_url)
      rescue Hanko::Error
        nil
      end

      def excluded_path?(path)
        Hanko::Rails.configuration.exclude_paths.any? { |p| path.start_with?(p) }
      end

      def jwks_url
        "#{Hanko.configuration.api_url}/.well-known/jwks.json"
      end
    end
  end
end
