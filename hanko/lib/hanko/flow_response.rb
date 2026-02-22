# frozen_string_literal: true

module Hanko
  # Structured response from a Hanko passkey flow endpoint.
  #
  # Wraps the raw response hash and provides convenience accessors
  # for status, available actions, session token, and user ID.
  class FlowResponse
    # @return [Symbol, nil] the flow status (e.g. :completed, :error)
    attr_reader :status

    # @return [Array<Resource>] available actions in the current flow state
    attr_reader :actions

    # @return [String, nil] the session token, if present in the payload
    attr_reader :session_token

    # @return [String, nil] the user ID, if present in the payload
    attr_reader :user_id

    # @return [Hash] the raw response hash
    attr_reader :raw

    # Creates a new FlowResponse from a parsed response hash.
    #
    # @param data [Hash] the parsed JSON response from a flow endpoint
    def initialize(data)
      @raw = data
      @status = data["status"]&.to_sym
      @actions = (data["actions"] || []).map { |a| Resource.new(a) }
      @session_token = data.dig("payload", "session_token")
      @user_id = data.dig("payload", "user_id")
    end

    # Returns true when the flow has completed successfully.
    #
    # @return [Boolean]
    def completed?
      status == :completed
    end

    # Returns true when the flow has entered an error state.
    #
    # @return [Boolean]
    def error?
      status == :error
    end

    # Returns the raw response hash.
    #
    # @return [Hash]
    def to_h
      @raw
    end
  end
end
