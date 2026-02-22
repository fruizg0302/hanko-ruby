# frozen_string_literal: true

module Hanko
  module Rails
    module TestHelper
      def sign_in_as_hanko_user(user_id)
        Hanko::TestHelper.stub_jwks(api_url: Hanko.configuration.api_url)
        token = Hanko::TestHelper.generate_test_token(sub: user_id, exp: Time.now.to_i + 3600)
        cookie_name = Hanko::Rails.configuration.cookie_name
        set_cookie "#{cookie_name}=#{token}"
      end

      def sign_out_hanko_user
        cookie_name = Hanko::Rails.configuration.cookie_name
        set_cookie "#{cookie_name}="
      end
    end
  end
end
