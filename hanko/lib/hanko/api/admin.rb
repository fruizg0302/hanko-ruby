# frozen_string_literal: true

require_relative 'admin/users'
require_relative 'admin/emails'
require_relative 'admin/passwords'
require_relative 'admin/sessions'
require_relative 'admin/webauthn_credentials'
require_relative 'admin/metadata'
require_relative 'admin/webhooks'
require_relative 'admin/audit_logs'

module Hanko
  module Api
    # Namespace module for Hanko Admin API resource classes.
    module Admin
    end

    # Entry point for the Hanko Admin API, providing access to admin sub-resources.
    class AdminNamespace
      # Initialize the admin namespace.
      #
      # @param connection [Hanko::Connection] the HTTP connection to use
      # @return [AdminNamespace] a new AdminNamespace instance
      def initialize(connection)
        @connection = connection
      end

      # Access the users resource, optionally scoped to a specific user.
      #
      # @param user_id [String, nil] optional user ID to scope to a single user context
      # @return [Admin::Users, Admin::Users::UserContext] the users resource or a user-scoped context
      def users(user_id = nil)
        users_resource = Admin::Users.new(@connection)
        user_id ? users_resource.call(user_id) : users_resource
      end

      # Access the webhooks resource.
      #
      # @return [Admin::Webhooks] the webhooks resource
      def webhooks
        Admin::Webhooks.new(@connection)
      end

      # Access the audit logs resource.
      #
      # @return [Admin::AuditLogs] the audit logs resource
      def audit_logs
        Admin::AuditLogs.new(@connection)
      end
    end
  end
end
