# frozen_string_literal: true

module Hanko
  module Rails
    # Test helpers for simulating Hanko authentication in integration tests.
    #
    # Include this module in your test classes to sign in and out of Hanko
    # sessions without hitting the real Hanko API.
    #
    # @example Using in a Rails integration test
    #   class PostsTest < ActionDispatch::IntegrationTest
    #     include Hanko::Rails::TestHelper
    #
    #     test 'authenticated user can view posts' do
    #       sign_in_as_hanko_user('user-uuid-123')
    #       get posts_path
    #       assert_response :success
    #     end
    #   end
    module TestHelper
      # Signs in as a Hanko user by generating a test JWT and setting it as a cookie.
      #
      # Stubs the JWKS endpoint so the middleware can verify the test token.
      #
      # @param user_id [String] the Hanko user ID to authenticate as
      # @return [void]
      #
      # @example
      #   sign_in_as_hanko_user('user-uuid-123')
      def sign_in_as_hanko_user(user_id)
        Hanko::TestHelper.stub_jwks(api_url: Hanko.configuration.api_url)
        token = Hanko::TestHelper.generate_test_token(sub: user_id, exp: Time.now.to_i + 3600)
        cookie_name = Hanko::Rails.configuration.cookie_name
        set_cookie "#{cookie_name}=#{token}"
      end

      # Signs out the current Hanko user by clearing the session cookie.
      #
      # @return [void]
      #
      # @example
      #   sign_out_hanko_user
      def sign_out_hanko_user
        cookie_name = Hanko::Rails.configuration.cookie_name
        set_cookie "#{cookie_name}="
      end
    end
  end
end
