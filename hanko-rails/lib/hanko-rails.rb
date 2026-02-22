# frozen_string_literal: true

require 'hanko'
require_relative 'hanko/rails/version'
require_relative 'hanko/rails/configuration'
require_relative 'hanko/rails/middleware'
require_relative 'hanko/rails/authentication'
require_relative 'hanko/rails/test_helper'
require_relative 'hanko/rails/engine' if defined?(::Rails::Engine)

module Hanko
  module Rails
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
end
