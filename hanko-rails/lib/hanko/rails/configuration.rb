# frozen_string_literal: true

module Hanko
  module Rails
    class Configuration
      attr_accessor :cookie_name, :jwks_cache_ttl, :exclude_paths

      def initialize
        @cookie_name = 'hanko'
        @jwks_cache_ttl = 3600
        @exclude_paths = []
      end
    end
  end
end
