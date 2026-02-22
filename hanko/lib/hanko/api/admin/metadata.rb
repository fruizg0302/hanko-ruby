# frozen_string_literal: true

module Hanko
  module Api
    module Admin
      class Metadata
        def initialize(connection, user_base_path)
          @connection = connection
          @base_path = "#{user_base_path}/metadata"
        end

        def get
          response = @connection.get(@base_path)
          Resource.new(JSON.parse(response.body))
        end

        def update(**params)
          response = @connection.patch(@base_path, params)
          Resource.new(JSON.parse(response.body))
        end
      end
    end
  end
end
