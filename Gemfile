# frozen_string_literal: true

source 'https://rubygems.org'

# Development: load both gems from path
gem 'hanko', path: 'hanko'
gem 'hanko-rails', path: 'hanko-rails'

group :development, :test do
  gem 'rake', '~> 13.0'
  gem 'rspec', '~> 3.12'
  gem 'rubocop', '~> 1.60'
  gem 'rubocop-rspec', '~> 3.0'
  gem 'simplecov', '~> 0.22', require: false
  gem 'webmock', '~> 3.19'
  gem 'yard', '~> 0.9'
end

# Rails needed for hanko-rails specs
group :test do
  gem 'rails', '~> 8.0'
  gem 'rspec-rails', '~> 7.0'
end
