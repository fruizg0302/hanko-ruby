# frozen_string_literal: true

require 'rails/generators'

module Hanko
  module Rails
    module Generators
      # Rails generator that scaffolds the Hanko initializer file.
      #
      # Run with:
      #   rails generate hanko:install
      class InstallGenerator < ::Rails::Generators::Base
        source_root File.expand_path('templates', __dir__)

        desc 'Creates a Hanko initializer for your Rails application'

        # Copies the Hanko initializer template into +config/initializers/hanko.rb+.
        #
        # @return [void]
        def copy_initializer
          template 'initializer.rb.tt', 'config/initializers/hanko.rb'
        end

        # Prints post-install instructions to the console.
        #
        # @return [void]
        def show_next_steps
          say ''
          say 'Hanko initializer created at config/initializers/hanko.rb', :green
          say ''
          say 'Next steps:'
          say '  1. Set your Hanko API URL in the initializer'
          say '  2. Include Hanko::Rails::Authentication in your ApplicationController'
          say '  3. Use authenticate_hanko_user! as a before_action where needed'
          say ''
        end
      end
    end
  end
end
