# frozen_string_literal: true

module Hanko
  module Api
    module Admin
      # Admin resource for managing a user's sessions.
      # Inherits list, get, create, update, delete from {BaseResource}.
      class Sessions < BaseResource
        # Initialize the sessions resource scoped to a user.
        #
        # @param connection [Hanko::Connection] the HTTP connection to use
        # @param user_base_path [String] the base path for the parent user (e.g. "/users/:id")
        # @return [Sessions] a new Sessions instance
        def initialize(connection, user_base_path)
          super(connection, "#{user_base_path}/sessions")
        end
      end
    end
  end
end
