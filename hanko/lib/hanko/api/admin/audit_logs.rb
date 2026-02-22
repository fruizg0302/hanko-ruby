# frozen_string_literal: true

module Hanko
  module Api
    module Admin
      # Admin resource for querying audit logs.
      # Inherits list, get, create, update, delete from {BaseResource}.
      class AuditLogs < BaseResource
        # Initialize the audit logs resource.
        #
        # @param connection [Hanko::Connection] the HTTP connection to use
        # @return [AuditLogs] a new AuditLogs instance
        def initialize(connection)
          super(connection, '/audit_logs')
        end
      end
    end
  end
end
