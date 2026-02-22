# frozen_string_literal: true

module Hanko
  module Api
    module Admin
      # Admin resource for managing a user's metadata.
      class Metadata
        # Initialize the metadata resource scoped to a user.
        #
        # @param connection [Hanko::Connection] the HTTP connection to use
        # @param user_base_path [String] the base path for the parent user (e.g. "/users/:id")
        # @return [Metadata] a new Metadata instance
        def initialize(connection, user_base_path)
          @connection = connection
          @base_path = "#{user_base_path}/metadata"
        end

        # Fetch the user's metadata.
        #
        # @return [Resource] the metadata resource
        def get
          response = @connection.get(@base_path)
          Resource.new(JSON.parse(response.body))
        end

        # Update the user's metadata via PATCH.
        #
        # @param params [Hash] the metadata attributes to update
        # @return [Resource] the updated metadata resource
        def update(**params)
          response = @connection.patch(@base_path, params)
          Resource.new(JSON.parse(response.body))
        end
      end
    end
  end
end
