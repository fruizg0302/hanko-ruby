# frozen_string_literal: true

module Hanko
  class Client
    attr_reader :config

    def initialize(**options)
      @config = build_config(options)
      validate_config!
      @connection = Connection.new(@config)
    end

    def inspect
      "#<#{self.class} api_url=#{config.api_url.inspect} api_key=[REDACTED]>"
    end

    private

    def build_config(options)
      base = Hanko.configuration
      Configuration.new.tap do |c|
        Configuration::ATTRIBUTES.each do |attr|
          value = options.fetch(attr, base.send(attr))
          c.send(:"#{attr}=", value)
        end
      end
    end

    def validate_config!
      raise ConfigurationError, "api_url is required" unless config.api_url
    end
  end
end
