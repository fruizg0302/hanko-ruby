# frozen_string_literal: true

module Hanko
  module Api
    module Admin
      # Admin resource for managing a user's password.
      class Passwords
        # Initialize the passwords resource scoped to a user.
        #
        # @param connection [Hanko::Connection] the HTTP connection to use
        # @param user_base_path [String] the base path for the parent user (e.g. "/users/:id")
        # @return [Passwords] a new Passwords instance
        def initialize(connection, user_base_path)
          @connection = connection
          @base_path = "#{user_base_path}/password"
        end

        # Create a password for the user.
        #
        # @param params [Hash] the password attributes
        # @return [Resource] the created password resource
        def create(**params)
          response = @connection.post(@base_path, params)
          Resource.new(JSON.parse(response.body))
        end

        # Fetch the user's password resource.
        #
        # @return [Resource] the password resource
        def get
          response = @connection.get(@base_path)
          Resource.new(JSON.parse(response.body))
        end

        # Update the user's password.
        #
        # @param params [Hash] the password attributes to update
        # @return [Resource] the updated password resource
        def update(**params)
          response = @connection.put(@base_path, params)
          Resource.new(JSON.parse(response.body))
        end

        # Delete the user's password.
        #
        # @return [Boolean] true if deletion was successful
        def delete
          @connection.delete(@base_path)
          true
        end
      end
    end
  end
end
