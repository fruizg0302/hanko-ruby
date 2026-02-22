# frozen_string_literal: true

require_relative "public/sessions"

module Hanko
  module Api
    module Public
    end

    class PublicNamespace
      def initialize(connection)
        @connection = connection
      end

      def sessions
        Public::Sessions.new(@connection)
      end

      def well_known
        Public::WellKnown.new(@connection)
      end

      def flow
        Public::Flow.new(@connection)
      end
    end
  end
end
