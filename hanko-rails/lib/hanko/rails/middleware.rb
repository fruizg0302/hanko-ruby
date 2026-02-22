# frozen_string_literal: true

module Hanko
  module Rails
    class Middleware
      def initialize(app)
        @app = app
      end

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
