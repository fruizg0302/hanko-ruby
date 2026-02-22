# frozen_string_literal: true

module Hanko
  module Api
    module Public
      class Flow
        def initialize(connection)
          @connection = connection
        end

        def login(**params)
          post_flow("/login", params)
        end

        def registration(**params)
          post_flow("/registration", params)
        end

        def profile(**params)
          post_flow("/profile", params)
        end

        private

        def post_flow(path, params)
          body = params.empty? ? {} : params
          response = @connection.post(path, body)
          FlowResponse.new(JSON.parse(response.body))
        end
      end
    end
  end
end
