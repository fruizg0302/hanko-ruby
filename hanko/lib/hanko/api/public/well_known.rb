# frozen_string_literal: true

module Hanko
  module Api
    module Public
      class WellKnown
        def initialize(connection)
          @connection = connection
        end

        def jwks
          response = @connection.get("/.well-known/jwks.json")
          Resource.new(JSON.parse(response.body))
        end

        def config
          response = @connection.get("/.well-known/config")
          Resource.new(JSON.parse(response.body))
        end
      end
    end
  end
end
