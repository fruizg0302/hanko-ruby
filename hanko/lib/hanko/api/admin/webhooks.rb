# frozen_string_literal: true

module Hanko
  module Api
    module Admin
      class Webhooks < BaseResource
        def initialize(connection)
          super(connection, "/webhooks")
        end
      end
    end
  end
end
