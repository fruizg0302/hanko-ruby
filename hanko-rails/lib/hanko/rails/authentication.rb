# frozen_string_literal: true

require 'active_support/concern'

module Hanko
  module Rails
    # Controller concern that provides Hanko authentication helpers.
    #
    # Include this module in your +ApplicationController+ to gain access to
    # session inspection methods and a before-action guard.
    #
    # @example Include in ApplicationController
    #   class ApplicationController < ActionController::Base
    #     include Hanko::Rails::Authentication
    #     before_action :authenticate_hanko_user!
    #   end
    module Authentication
      extend ActiveSupport::Concern

      included do
        helper_method :hanko_session, :hanko_user_id, :hanko_authenticated?, :current_hanko_user
      end

      # Returns the decoded Hanko session payload from the verified JWT.
      #
      # @return [Hash, nil] the decoded JWT claims, or +nil+ if unauthenticated
      def hanko_session
        request.env['hanko.session']
      end

      # Returns the Hanko user ID (+sub+ claim) from the session.
      #
      # @return [String, nil] the user ID, or +nil+ if unauthenticated
      def hanko_user_id
        hanko_session&.dig('sub')
      end

      # Checks whether the current request has a valid Hanko session.
      #
      # @return [Boolean] +true+ if authenticated, +false+ otherwise
      def hanko_authenticated?
        !hanko_session.nil?
      end

      # Returns the current Hanko user identifier.
      #
      # @return [String, nil] the user ID, or +nil+ if unauthenticated
      def current_hanko_user
        hanko_user_id
      end

      # Halts the request with an unauthorized response unless the user is authenticated.
      #
      # For HTML requests, redirects to the root path with an alert.
      # For JSON and other formats, responds with HTTP 401 Unauthorized.
      #
      # @return [void]
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
