# frozen_string_literal: true

module Hanko
  module Rails
    # Rails engine that automatically inserts the Hanko authentication
    # middleware into the Rails middleware stack on boot.
    class Engine < ::Rails::Engine
      engine_name 'hanko_rails'

      initializer 'hanko_rails.middleware' do |app|
        app.middleware.use Hanko::Rails::Middleware
      end
    end
  end
end
