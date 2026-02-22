# frozen_string_literal: true

module Hanko
  module Api
    module Admin
      class AuditLogs < BaseResource
        def initialize(connection)
          super(connection, "/audit_logs")
        end
      end
    end
  end
end
