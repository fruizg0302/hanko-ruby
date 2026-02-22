# frozen_string_literal: true

module Hanko
  module Api
    module Public
      # Public resource for accessing .well-known discovery endpoints.
      class WellKnown
        # Initialize the well-known resource.
        #
        # @param connection [Hanko::Connection] the HTTP connection to use
        # @return [WellKnown] a new WellKnown instance
        def initialize(connection)
          @connection = connection
        end

        # Fetch the JSON Web Key Set (JWKS) for token verification.
        #
        # @return [Resource] the JWKS resource
        def jwks
          response = @connection.get("/.well-known/jwks.json")
          Resource.new(JSON.parse(response.body))
        end

        # Fetch the Hanko server configuration.
        #
        # @return [Resource] the configuration resource
        def config
          response = @connection.get("/.well-known/config")
          Resource.new(JSON.parse(response.body))
        end
      end
    end
  end
end
