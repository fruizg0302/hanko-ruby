# frozen_string_literal: true

require_relative 'hanko/version'
require_relative 'hanko/errors'
require_relative 'hanko/resource'
require_relative 'hanko/flow_response'
require_relative 'hanko/configuration'
require_relative 'hanko/middleware/raise_error'
require_relative 'hanko/connection'
require_relative 'hanko/api/base_resource'
require_relative 'hanko/api/admin'
require_relative 'hanko/api/public'
require_relative 'hanko/client'
require_relative 'hanko/webhook_verifier'
require_relative 'hanko/test_helper'

module Hanko
  class << self
    def configuration
      @configuration ||= Configuration.new
    end

    def configure
      yield(configuration)
    end

    def reset_configuration!
      @configuration = Configuration.new
    end
  end
end
