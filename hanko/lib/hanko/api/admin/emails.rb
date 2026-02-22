# frozen_string_literal: true

module Hanko
  module Api
    module Admin
      class Emails < BaseResource
        def initialize(connection, user_base_path)
          super(connection, "#{user_base_path}/emails")
          @connection = connection
        end

        def set_primary(email_id)
          response = @connection.post("#{@base_path}/#{email_id}/set_primary")
          parse_resource(response.body)
        end
      end
    end
  end
end
