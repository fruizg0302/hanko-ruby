# frozen_string_literal: true

module Hanko
  module Api
    module Admin
      class Passwords
        def initialize(connection, user_base_path)
          @connection = connection
          @base_path = "#{user_base_path}/password"
        end

        def create(**params)
          response = @connection.post(@base_path, params)
          Resource.new(JSON.parse(response.body))
        end

        def get
          response = @connection.get(@base_path)
          Resource.new(JSON.parse(response.body))
        end

        def update(**params)
          response = @connection.put(@base_path, params)
          Resource.new(JSON.parse(response.body))
        end

        def delete
          @connection.delete(@base_path)
          true
        end
      end
    end
  end
end
