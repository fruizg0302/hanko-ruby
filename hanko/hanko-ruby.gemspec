# frozen_string_literal: true

require_relative 'lib/hanko/version'

Gem::Specification.new do |spec|
  spec.name          = 'hanko-ruby'
  spec.version       = Hanko::VERSION
  spec.authors       = ['Fernando Ruiz']
  spec.email         = ['fruizg0302@me.com']

  spec.summary       = 'Ruby SDK for the Hanko authentication platform'
  spec.description   = 'Full-featured Ruby client for the Hanko API: ' \
                       'session verification (JWKS/JWT), Admin API, Flow API, and webhook verification.'
  spec.homepage      = 'https://github.com/fruizg0302/hanko-ruby'
  spec.license       = 'MIT'

  spec.required_ruby_version = '>= 3.1'

  spec.metadata['homepage_uri']    = spec.homepage
  spec.metadata['source_code_uri'] = spec.homepage
  spec.metadata['changelog_uri']   = "#{spec.homepage}/blob/main/CHANGELOG.md"
  spec.metadata['rubygems_mfa_required'] = 'true'

  spec.files = Dir['lib/**/*', 'LICENSE.txt', 'README.md']
  spec.require_paths = ['lib']

  spec.add_dependency 'concurrent-ruby', '~> 1.0'
  spec.add_dependency 'faraday', '~> 2.0'
  spec.add_dependency 'jwt', '~> 2.7'
end
