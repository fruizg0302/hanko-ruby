# frozen_string_literal: true

module Hanko
  module Api
    module Public
      # Public resource for validating Hanko sessions.
      class Sessions
        # Initialize the public sessions resource.
        #
        # @param connection [Hanko::Connection] the HTTP connection to use
        # @return [Sessions] a new Sessions instance
        def initialize(connection)
          @connection = connection
        end

        # Validate the current session using cookies/headers from the connection.
        #
        # @return [Resource] the validated session resource
        def validate
          response = @connection.get("/sessions/validate")
          Resource.new(JSON.parse(response.body))
        end

        # Validate a session by providing an explicit session token.
        #
        # @param session_token [String] the session token to validate
        # @return [Resource] the validated session resource
        def validate_token(session_token)
          response = @connection.post("/sessions/validate", session_token: session_token)
          Resource.new(JSON.parse(response.body))
        end
      end
    end
  end
end
