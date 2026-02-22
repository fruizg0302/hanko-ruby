# frozen_string_literal: true

require_relative "public/sessions"
require_relative "public/well_known"
require_relative "public/flow"

module Hanko
  module Api
    # Namespace module for Hanko Public API resource classes.
    module Public
    end

    # Entry point for the Hanko Public API, providing access to public sub-resources.
    class PublicNamespace
      # Initialize the public namespace.
      #
      # @param connection [Hanko::Connection] the HTTP connection to use
      # @return [PublicNamespace] a new PublicNamespace instance
      def initialize(connection)
        @connection = connection
      end

      # Access the sessions resource for session validation.
      #
      # @return [Public::Sessions] the sessions resource
      def sessions
        Public::Sessions.new(@connection)
      end

      # Access the .well-known resource for JWKS and configuration discovery.
      #
      # @return [Public::WellKnown] the well-known resource
      def well_known
        Public::WellKnown.new(@connection)
      end

      # Access the flow resource for login, registration, and profile flows.
      #
      # @return [Public::Flow] the flow resource
      def flow
        Public::Flow.new(@connection)
      end
    end
  end
end
