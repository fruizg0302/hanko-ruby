# frozen_string_literal: true

require "json"

module Hanko
  module Api
    class BaseResource
      def initialize(connection, base_path)
        @connection = connection
        @base_path = base_path
      end

      def list(params = {})
        response = @connection.get(@base_path, params)
        parse_array(response.body)
      end

      def get(id)
        response = @connection.get("#{@base_path}/#{id}")
        parse_resource(response.body)
      end

      def create(**params)
        response = @connection.post(@base_path, params)
        parse_resource(response.body)
      end

      def update(id, **params)
        response = @connection.put("#{@base_path}/#{id}", params)
        parse_resource(response.body)
      end

      def delete(id)
        @connection.delete("#{@base_path}/#{id}")
        true
      end

      private

      def parse_resource(body)
        data = body.is_a?(String) ? JSON.parse(body) : body
        Resource.new(data)
      end

      def parse_array(body)
        data = body.is_a?(String) ? JSON.parse(body) : body
        Resource.from_array(data)
      end
    end
  end
end
