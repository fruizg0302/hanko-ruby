# frozen_string_literal: true

require_relative "admin/users"
require_relative "admin/emails"
require_relative "admin/passwords"
require_relative "admin/sessions"
require_relative "admin/webauthn_credentials"

module Hanko
  module Api
    module Admin
    end

    class AdminNamespace
      def initialize(connection)
        @connection = connection
      end

      def users(user_id = nil)
        users_resource = Admin::Users.new(@connection)
        user_id ? users_resource.call(user_id) : users_resource
      end

      def webhooks
        Admin::Webhooks.new(@connection)
      end

      def audit_logs
        Admin::AuditLogs.new(@connection)
      end
    end
  end
end
