# frozen_string_literal: true

module Hanko
  module Api
    module Public
      # Public resource for initiating authentication and profile flows.
      class Flow
        # Initialize the flow resource.
        #
        # @param connection [Hanko::Connection] the HTTP connection to use
        # @return [Flow] a new Flow instance
        def initialize(connection)
          @connection = connection
        end

        # Initiate a login flow.
        #
        # @param params [Hash] optional parameters for the login flow
        # @return [FlowResponse] the login flow response
        def login(**params)
          post_flow('/login', params)
        end

        # Initiate a registration flow.
        #
        # @param params [Hash] optional parameters for the registration flow
        # @return [FlowResponse] the registration flow response
        def registration(**params)
          post_flow('/registration', params)
        end

        # Initiate a profile management flow.
        #
        # @param params [Hash] optional parameters for the profile flow
        # @return [FlowResponse] the profile flow response
        def profile(**params)
          post_flow('/profile', params)
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
