# frozen_string_literal: true

module Hanko
  module Api
    module Admin
      # Admin resource for managing a user's email addresses.
      # Inherits list, get, create, update, delete from {BaseResource}.
      class Emails < BaseResource
        # Initialize the emails resource scoped to a user.
        #
        # @param connection [Hanko::Connection] the HTTP connection to use
        # @param user_base_path [String] the base path for the parent user (e.g. "/users/:id")
        # @return [Emails] a new Emails instance
        def initialize(connection, user_base_path)
          super(connection, "#{user_base_path}/emails")
          @connection = connection
        end

        # Mark an email address as the primary email for the user.
        #
        # @param email_id [String] the unique identifier of the email to make primary
        # @return [Resource] the updated email resource
        def make_primary(email_id)
          response = @connection.post("#{@base_path}/#{email_id}/set_primary")
          parse_resource(response.body)
        end
      end
    end
  end
end
