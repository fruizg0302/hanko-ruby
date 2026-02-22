# frozen_string_literal: true

module Hanko
  module Api
    module Public
      class Sessions
        def initialize(connection)
          @connection = connection
        end

        def validate
          response = @connection.get("/sessions/validate")
          Resource.new(JSON.parse(response.body))
        end

        def validate_token(session_token)
          response = @connection.post("/sessions/validate", session_token: session_token)
          Resource.new(JSON.parse(response.body))
        end
      end
    end
  end
end
