# hanko-rails

[![CI](https://github.com/fruizg0302/hanko-ruby/actions/workflows/ci.yml/badge.svg)](https://github.com/fruizg0302/hanko-ruby/actions)
[![Gem Version](https://badge.fury.io/rb/hanko-rails.svg)](https://rubygems.org/gems/hanko-rails)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

Rails integration for the [Hanko](https://www.hanko.io/) authentication platform. Provides Rack middleware for automatic session verification, controller helpers, an install generator, and test helpers.

> **Using Ruby without Rails?** See [hanko-ruby](https://rubygems.org/gems/hanko-ruby) for the framework-agnostic SDK.

## Installation

```ruby
# Gemfile
gem 'hanko-rails'   # pulls in hanko-ruby automatically
```

```sh
bundle install
```

## Setup

Generate the initializer:

```sh
bin/rails generate hanko:install
```

This creates `config/initializers/hanko.rb`:

```ruby
Hanko.configure do |config|
  config.api_url = ENV.fetch('HANKO_API_URL', 'https://your-hanko-instance.hanko.io')
  # config.api_key = ENV.fetch('HANKO_API_KEY', nil)
end

Hanko::Rails.configure do |config|
  # config.cookie_name = 'hanko'
  # config.exclude_paths = ['/healthz', '/up']
  # config.jwks_cache_ttl = 3600
end
```

## Middleware

`Hanko::Rails::Middleware` is automatically inserted into the Rack stack by the engine. It:

1. Extracts tokens from the `hanko` cookie or `Authorization: Bearer` header
2. Verifies the JWT against the JWKS endpoint
3. Sets `request.env['hanko.session']` with the decoded payload

Configure which paths to skip:

```ruby
Hanko::Rails.configure do |config|
  config.exclude_paths = ['/healthz', '/up', '/assets']
end
```

## Authentication Concern

Include `Hanko::Rails::Authentication` in your controllers:

```ruby
class ApplicationController < ActionController::Base
  include Hanko::Rails::Authentication

  before_action :authenticate_hanko_user!
end
```

### Available helpers

| Helper | Returns |
|--------|---------|
| `hanko_session` | Decoded JWT payload hash, or `nil` |
| `hanko_user_id` | The `sub` claim (user UUID), or `nil` |
| `hanko_authenticated?` | `true` if a valid session exists |
| `current_hanko_user` | Alias for `hanko_user_id` |
| `authenticate_hanko_user!` | Redirects (HTML) or returns 401 (JSON) if unauthenticated |

All helpers except `authenticate_hanko_user!` are also available in views.

## Using with your User model

```ruby
class ApplicationController < ActionController::Base
  include Hanko::Rails::Authentication

  def current_user
    @current_user ||= User.find_by(hanko_id: hanko_user_id) if hanko_authenticated?
  end
  helper_method :current_user
end
```

## Testing

The test helper is **opt-in** — require it explicitly:

```ruby
require 'hanko/rails/test_helper'
```

### Setup with RSpec

```ruby
# spec/support/hanko.rb
require 'hanko/rails/test_helper'

RSpec.configure do |config|
  config.include Hanko::Rails::TestHelper, type: :request
end
```

### Usage

```ruby
RSpec.describe 'Dashboard', type: :request do
  it 'requires authentication' do
    get '/dashboard'
    expect(response).to have_http_status(:unauthorized)
  end

  it 'shows dashboard for authenticated user' do
    sign_in_as_hanko_user('user-uuid')
    get '/dashboard'
    expect(response).to have_http_status(:ok)
  end

  it 'handles sign out' do
    sign_in_as_hanko_user('user-uuid')
    sign_out_hanko_user
    get '/dashboard'
    expect(response).to have_http_status(:unauthorized)
  end
end
```

## Configuration Options

| Option | Default | Description |
|--------|---------|-------------|
| `cookie_name` | `'hanko'` | Name of the cookie holding the Hanko JWT |
| `jwks_cache_ttl` | `3600` | JWKS cache lifetime in seconds |
| `exclude_paths` | `[]` | Request path prefixes that skip verification |

## Requirements

- Ruby >= 3.1
- Rails >= 7.0

## Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/my-feature`)
3. Write tests for your changes
4. Ensure all tests pass: `bundle exec rspec`
5. Ensure linting passes: `bundle exec rubocop`
6. Commit your changes (`git commit -m 'Add my feature'`)
7. Push to the branch (`git push origin feature/my-feature`)
8. Open a Pull Request

## License

Released under the [MIT License](LICENSE.txt).
