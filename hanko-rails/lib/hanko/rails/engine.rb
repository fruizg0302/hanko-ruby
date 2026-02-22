# frozen_string_literal: true

module Hanko
  module Rails
    class Engine < ::Rails::Engine
      engine_name 'hanko_rails'

      initializer 'hanko_rails.middleware' do |app|
        app.middleware.use Hanko::Rails::Middleware
      end
    end
  end
end
