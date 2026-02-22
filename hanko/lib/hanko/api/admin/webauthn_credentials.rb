# frozen_string_literal: true

module Hanko
  module Api
    module Admin
      class WebauthnCredentials < BaseResource
        def initialize(connection, user_base_path)
          super(connection, "#{user_base_path}/webauthn_credentials")
        end
      end
    end
  end
end
