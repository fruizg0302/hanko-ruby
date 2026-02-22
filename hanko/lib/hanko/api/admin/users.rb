# frozen_string_literal: true

module Hanko
  module Api
    module Admin
      class Users < BaseResource
        def initialize(connection)
          super(connection, "/users")
          @connection = connection
        end

        def call(user_id)
          UserContext.new(@connection, user_id)
        end

        class UserContext
          def initialize(connection, user_id)
            @connection = connection
            @user_id = user_id
            @base_path = "/users/#{user_id}"
          end

          def emails
            Emails.new(@connection, @base_path)
          end

          def passwords
            Passwords.new(@connection, @base_path)
          end

          def sessions
            Sessions.new(@connection, @base_path)
          end

          def webauthn_credentials
            WebauthnCredentials.new(@connection, @base_path)
          end

          def metadata
            Metadata.new(@connection, @base_path)
          end
        end
      end
    end
  end
end
