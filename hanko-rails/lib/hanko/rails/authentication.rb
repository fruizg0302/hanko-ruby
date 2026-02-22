# frozen_string_literal: true

require 'active_support/concern'

module Hanko
  module Rails
    module Authentication
      extend ActiveSupport::Concern

      included do
        helper_method :hanko_session, :hanko_user_id, :hanko_authenticated?, :current_hanko_user
      end

      def hanko_session
        request.env['hanko.session']
      end

      def hanko_user_id
        hanko_session&.dig('sub')
      end

      def hanko_authenticated?
        !hanko_session.nil?
      end

      def current_hanko_user
        hanko_user_id
      end

      def authenticate_hanko_user!
        return if hanko_authenticated?

        respond_to do |format|
          format.html { redirect_to('/', alert: 'You must be logged in') }
          format.json { head(:unauthorized) }
          format.any { head(:unauthorized) }
        end
      end
    end
  end
end
