# frozen_string_literal: true

module Hanko
  module Api
    module Admin
      # Admin resource for managing webhooks.
      # Inherits list, get, create, update, delete from {BaseResource}.
      class Webhooks < BaseResource
        # Initialize the webhooks resource.
        #
        # @param connection [Hanko::Connection] the HTTP connection to use
        # @return [Webhooks] a new Webhooks instance
        def initialize(connection)
          super(connection, '/webhooks')
        end
      end
    end
  end
end
