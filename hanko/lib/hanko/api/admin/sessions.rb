# frozen_string_literal: true

module Hanko
  module Api
    module Admin
      class Sessions < BaseResource
        def initialize(connection, user_base_path)
          super(connection, "#{user_base_path}/sessions")
        end
      end
    end
  end
end
