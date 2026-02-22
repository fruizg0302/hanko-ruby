# frozen_string_literal: true

require_relative 'lib/hanko/rails/version'

Gem::Specification.new do |spec|
  spec.name          = 'hanko-rails'
  spec.version       = Hanko::Rails::VERSION
  spec.authors       = ['Fernando Ruiz']
  spec.email         = ['fruizg0302@me.com']

  spec.summary       = 'Rails integration for the Hanko authentication platform'
  spec.description   = 'Rack middleware, controller concerns, and generators for ' \
                       'integrating Hanko authentication into Rails applications.'
  spec.homepage      = 'https://github.com/fruizg0302/hanko-ruby'
  spec.license       = 'MIT'

  spec.required_ruby_version = '>= 3.1'

  spec.metadata['homepage_uri']    = spec.homepage
  spec.metadata['source_code_uri'] = "#{spec.homepage}/tree/main/hanko-rails"
  spec.metadata['changelog_uri']   = "#{spec.homepage}/blob/main/CHANGELOG.md"
  spec.metadata['rubygems_mfa_required'] = 'true'

  spec.files = Dir['lib/**/*', 'LICENSE.txt', 'README.md']
  spec.require_paths = ['lib']

  spec.add_dependency 'hanko-ruby', Hanko::Rails::VERSION
  spec.add_dependency 'railties', '>= 7.0', '< 9.0'
end
