# frozen_string_literal: true

module Hanko
  module Api
    module Admin
      # Admin resource for managing users.
      # Inherits list, get, create, update, delete from {BaseResource}.
      class Users < BaseResource
        # Initialize the users resource.
        #
        # @param connection [Hanko::Connection] the HTTP connection to use
        # @return [Users] a new Users instance
        def initialize(connection)
          super(connection, '/users')
          @connection = connection
        end

        # Return a user-scoped context for accessing sub-resources.
        #
        # @param user_id [String] the unique identifier of the user
        # @return [UserContext] a context scoped to the given user
        def call(user_id)
          UserContext.new(@connection, user_id)
        end

        # Provides access to sub-resources scoped to a specific user.
        class UserContext
          # Initialize a user-scoped context.
          #
          # @param connection [Hanko::Connection] the HTTP connection to use
          # @param user_id [String] the unique identifier of the user
          # @return [UserContext] a new UserContext instance
          def initialize(connection, user_id)
            @connection = connection
            @user_id = user_id
            @base_path = "/users/#{user_id}"
          end

          # Access the emails sub-resource for this user.
          #
          # @return [Emails] the emails resource scoped to this user
          def emails
            Emails.new(@connection, @base_path)
          end

          # Access the passwords sub-resource for this user.
          #
          # @return [Passwords] the passwords resource scoped to this user
          def passwords
            Passwords.new(@connection, @base_path)
          end

          # Access the sessions sub-resource for this user.
          #
          # @return [Sessions] the sessions resource scoped to this user
          def sessions
            Sessions.new(@connection, @base_path)
          end

          # Access the WebAuthn credentials sub-resource for this user.
          #
          # @return [WebauthnCredentials] the WebAuthn credentials resource scoped to this user
          def webauthn_credentials
            WebauthnCredentials.new(@connection, @base_path)
          end

          # Access the metadata sub-resource for this user.
          #
          # @return [Metadata] the metadata resource scoped to this user
          def metadata
            Metadata.new(@connection, @base_path)
          end
        end
      end
    end
  end
end
