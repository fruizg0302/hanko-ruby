# frozen_string_literal: true

require 'rails/generators'

module Hanko
  module Rails
    module Generators
      class InstallGenerator < ::Rails::Generators::Base
        source_root File.expand_path('templates', __dir__)

        desc 'Creates a Hanko initializer for your Rails application'

        def copy_initializer
          template 'initializer.rb.tt', 'config/initializers/hanko.rb'
        end

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
