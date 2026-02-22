# frozen_string_literal: true

module Hanko
  class Configuration
    ATTRIBUTES = %i[
      api_url api_key timeout open_timeout retry_count
      clock_skew jwks_cache_ttl logger log_level
    ].freeze

    attr_accessor(*ATTRIBUTES)

    def initialize
      @timeout = 5
      @open_timeout = 2
      @retry_count = 1
      @clock_skew = 0
      @jwks_cache_ttl = 3600
      @log_level = :info
    end

    def inspect
      attrs = ATTRIBUTES.map do |key|
        value = send(key)
        value = '[REDACTED]' if key == :api_key && value
        "#{key}=#{value.inspect}"
      end
      "#<#{self.class} #{attrs.join(', ')}>"
    end
  end
end
