# frozen_string_literal: true

module Hanko
  class FlowResponse
    attr_reader :status, :actions, :session_token, :user_id, :raw

    def initialize(data)
      @raw = data
      @status = data["status"]&.to_sym
      @actions = (data["actions"] || []).map { |a| Resource.new(a) }
      @session_token = data.dig("payload", "session_token")
      @user_id = data.dig("payload", "user_id")
    end

    def completed?
      status == :completed
    end

    def error?
      status == :error
    end

    def to_h
      @raw
    end
  end
end
