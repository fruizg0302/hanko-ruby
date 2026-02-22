# frozen_string_literal: true

require "json"

module Hanko
  module Api
    # Base class for RESTful API resources providing standard CRUD operations.
    # Subclasses inherit {#list}, {#get}, {#create}, {#update}, and {#delete}.
    class BaseResource
      # Initialize a new resource endpoint.
      #
      # @param connection [Hanko::Connection] the HTTP connection to use
      # @param base_path [String] the base API path for this resource
      # @return [BaseResource] a new BaseResource instance
      def initialize(connection, base_path)
        @connection = connection
        @base_path = base_path
      end

      # List all resources, optionally filtered by query parameters.
      #
      # @param params [Hash] optional query parameters for filtering
      # @return [Array<Resource>] an array of Resource objects
      def list(params = {})
        response = @connection.get(@base_path, params)
        parse_array(response.body)
      end

      # Fetch a single resource by its ID.
      #
      # @param id [String] the unique identifier of the resource
      # @return [Resource] the requested resource
      def get(id)
        response = @connection.get("#{@base_path}/#{id}")
        parse_resource(response.body)
      end

      # Create a new resource with the given attributes.
      #
      # @param params [Hash] the attributes for the new resource
      # @return [Resource] the newly created resource
      def create(**params)
        response = @connection.post(@base_path, params)
        parse_resource(response.body)
      end

      # Update an existing resource by its ID.
      #
      # @param id [String] the unique identifier of the resource
      # @param params [Hash] the attributes to update
      # @return [Resource] the updated resource
      def update(id, **params)
        response = @connection.put("#{@base_path}/#{id}", params)
        parse_resource(response.body)
      end

      # Delete a resource by its ID.
      #
      # @param id [String] the unique identifier of the resource
      # @return [Boolean] true if deletion was successful
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
