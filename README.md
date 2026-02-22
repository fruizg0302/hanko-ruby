# Hanko Ruby SDK

[![CI](https://github.com/fruizg0302/hanko-ruby/actions/workflows/ci.yml/badge.svg)](https://github.com/fruizg0302/hanko-ruby/actions)
[![Gem Version](https://badge.fury.io/rb/hanko-ruby.svg)](https://rubygems.org/gems/hanko-ruby)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

Ruby SDK for the [Hanko](https://www.hanko.io/) authentication platform. Verify sessions, manage users via the Admin API, drive login/registration flows, and handle webhooks -- all from Ruby.

## Gems

| Gem | Description |
|-----|-------------|
| **[hanko-ruby](hanko/)** | Core Ruby client (framework-agnostic). Session verification, Admin API, Flow API, webhook verification. |
| **[hanko-ruby-rails](hanko-rails/)** | Rails integration. Rack middleware, controller concern, install generator, and test helpers. |

## Installation

### Core gem only (any Ruby app)

```ruby
# Gemfile
gem 'hanko-ruby'
```

### With Rails integration

```ruby
# Gemfile
gem 'hanko-ruby-rails'   # pulls in hanko-ruby automatically
```

Then run:

```sh
bundle install
```

## Quick Start

Verify a Hanko session token in three lines:

```ruby
require 'hanko'

Hanko.configure do |config|
  config.api_url = 'https://your-instance.hanko.io'
end

client = Hanko::Client.new
result = client.public.sessions.validate_token(session_token)
puts result['user_id']
```

## Configuration

### Global configuration

Set defaults that apply to every `Hanko::Client` instance:

```ruby
Hanko.configure do |config|
  config.api_url        = ENV.fetch('HANKO_API_URL')
  config.api_key        = ENV.fetch('HANKO_API_KEY')  # required for Admin API
  config.timeout        = 5       # request timeout in seconds (default: 5)
  config.open_timeout   = 2       # connection open timeout (default: 2)
  config.retry_count    = 1       # number of retries (default: 1)
  config.clock_skew     = 0       # allowed JWT clock skew in seconds (default: 0)
  config.jwks_cache_ttl = 3600    # JWKS cache lifetime in seconds (default: 3600)
  config.logger         = Rails.logger
  config.log_level      = :info   # default: :info
end
```

### Per-client overrides

Override any setting on a specific client instance:

```ruby
admin_client = Hanko::Client.new(
  api_url: 'https://your-instance.hanko.io',
  api_key: ENV.fetch('HANKO_API_KEY'),
  timeout: 10
)
```

Global and per-client settings can be mixed; per-client values take precedence.

## Session Verification

The primary use case: verify a Hanko JWT using the instance's JWKS endpoint.

### Via the Public API

```ruby
client = Hanko::Client.new

# Validate using a session token string
result = client.public.sessions.validate_token(session_token)

# Validate using cookie/header (server-side forwarding)
result = client.public.sessions.validate
```

### Via WebhookVerifier (standalone)

For lightweight verification without a full client:

```ruby
payload = Hanko::WebhookVerifier.verify(
  token,
  jwks_url: 'https://your-instance.hanko.io/.well-known/jwks.json'
)

puts payload['sub']  # user ID
```

The verifier pins to RS256 and raises `Hanko::InvalidTokenError` or `Hanko::ExpiredTokenError` on failure.

## Admin API

The Admin API requires an API key. All responses are wrapped in `Hanko::Resource` objects that support both hash-style (`resource['field']`) and method-style (`resource.field`) access.

### Users

```ruby
client = Hanko::Client.new

# List users
users = client.admin.users.list
users.each { |u| puts u.id }

# Get a specific user
user = client.admin.users.get('user-uuid')

# Create a user
user = client.admin.users.create(email: 'alice@example.com')

# Delete a user
client.admin.users.delete('user-uuid')
```

### User-scoped resources

Access emails, passwords, sessions, WebAuthn credentials, and metadata through a user context:

```ruby
user_ctx = client.admin.users('user-uuid')

# Emails
emails = user_ctx.emails.list
user_ctx.emails.create(address: 'new@example.com')
user_ctx.emails.set_primary('email-uuid')
user_ctx.emails.delete('email-uuid')

# Passwords
user_ctx.passwords.create(password: 'new-password')
user_ctx.passwords.get
user_ctx.passwords.update(password: 'updated-password')
user_ctx.passwords.delete

# Sessions
sessions = user_ctx.sessions.list
user_ctx.sessions.delete('session-uuid')

# WebAuthn credentials
creds = user_ctx.webauthn_credentials.list
user_ctx.webauthn_credentials.delete('credential-uuid')

# Metadata
meta = user_ctx.metadata.get
user_ctx.metadata.update(custom_key: 'custom_value')
```

### Webhooks

```ruby
# List webhooks
webhooks = client.admin.webhooks.list

# Create a webhook
webhook = client.admin.webhooks.create(
  callback: 'https://example.com/webhooks/hanko',
  events: ['user.create', 'user.delete']
)

# Delete a webhook
client.admin.webhooks.delete('webhook-uuid')
```

### Audit Logs

```ruby
logs = client.admin.audit_logs.list
logs.each { |log| puts "#{log.type} at #{log.created_at}" }
```

## Flow API

Drive Hanko login and registration flows server-side. Returns `Hanko::FlowResponse` objects.

```ruby
client = Hanko::Client.new

# Start a login flow
response = client.public.flow.login
puts response.status   # :completed, :error, etc.
puts response.actions  # available next actions

# Start a registration flow
response = client.public.flow.registration

# Profile flow
response = client.public.flow.profile

# Check flow state
if response.completed?
  puts "User ID: #{response.user_id}"
  puts "Session token: #{response.session_token}"
elsif response.error?
  puts "Flow failed"
end
```

## Well-Known Endpoints

```ruby
client = Hanko::Client.new

# Fetch JWKS
jwks = client.public.well_known.jwks

# Fetch Hanko configuration
config = client.public.well_known.config
```

## Webhook Verification

Verify incoming webhook payloads from Hanko:

```ruby
class WebhooksController < ApplicationController
  skip_before_action :verify_authenticity_token

  def create
    token = request.headers['X-Hanko-Webhook-Token']
    payload = Hanko::WebhookVerifier.verify(
      token,
      jwks_url: "#{ENV.fetch('HANKO_API_URL')}/.well-known/jwks.json"
    )

    case payload['evt']
    when 'user.create'
      User.create!(hanko_id: payload['sub'])
    when 'user.delete'
      User.find_by(hanko_id: payload['sub'])&.destroy
    end

    head :ok
  rescue Hanko::InvalidTokenError, Hanko::ExpiredTokenError => e
    head :unauthorized
  end
end
```

## Rails Integration

The `hanko-ruby-rails` gem provides automatic session verification, controller helpers, and an install generator.

### Setup

```sh
# Generate the initializer
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

### Middleware

The `Hanko::Rails::Middleware` is automatically inserted into the Rack stack by the engine. It:

1. Extracts tokens from the `hanko` cookie or `Authorization: Bearer` header
2. Verifies the JWT against the JWKS endpoint
3. Sets `request.env['hanko.session']` with the decoded payload

Configure which paths to skip:

```ruby
Hanko::Rails.configure do |config|
  config.exclude_paths = ['/healthz', '/up', '/assets']
end
```

### Authentication Concern

Include `Hanko::Rails::Authentication` in your controllers:

```ruby
class ApplicationController < ActionController::Base
  include Hanko::Rails::Authentication

  before_action :authenticate_hanko_user!
end
```

Available helpers:

| Helper | Returns |
|--------|---------|
| `hanko_session` | Decoded JWT payload hash, or `nil` |
| `hanko_user_id` | The `sub` claim (user UUID), or `nil` |
| `hanko_authenticated?` | `true` if a valid session exists |
| `current_hanko_user` | Alias for `hanko_user_id` |
| `authenticate_hanko_user!` | Redirects (HTML) or returns 401 (JSON) if unauthenticated |

All helpers except `authenticate_hanko_user!` are also available in views.

### Using with your User model

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

Both gems ship with test helpers to make it easy to write specs without hitting the Hanko API.

### Core gem: `Hanko::TestHelper`

```ruby
require 'hanko/test_helper'

# Generate a signed JWT for testing
token = Hanko::TestHelper.generate_test_token(
  sub: 'user-uuid',
  exp: Time.now.to_i + 3600
)

# Get a JWKS response body (matches the test signing key)
jwks_json = Hanko::TestHelper.test_jwks_response

# Stub the JWKS endpoint (requires WebMock)
Hanko::TestHelper.stub_jwks(api_url: 'https://your-instance.hanko.io')

# Create a stub verifier (no HTTP calls)
verifier = Hanko::TestHelper.stub_session(
  sub: 'user-uuid',
  exp: Time.now.to_i + 3600
)
payload = verifier.verify('any-token')
puts payload['sub']  # => 'user-uuid'
```

### Rails gem: `Hanko::Rails::TestHelper`

```ruby
# spec/support/hanko.rb
RSpec.configure do |config|
  config.include Hanko::Rails::TestHelper, type: :request
end

# In your request specs
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
end
```

## Error Handling

All errors inherit from `Hanko::Error`. The hierarchy:

```
Hanko::Error
├── Hanko::ConfigurationError    # missing or invalid configuration
├── Hanko::InvalidTokenError     # JWT signature invalid or malformed
├── Hanko::ExpiredTokenError     # JWT has expired
├── Hanko::JwksError             # failed to fetch or parse JWKS
├── Hanko::ConnectionError       # network-level failure
└── Hanko::ApiError              # HTTP 4xx/5xx response
    ├── Hanko::AuthenticationError   # 401 Unauthorized
    ├── Hanko::NotFoundError         # 404 Not Found
    └── Hanko::RateLimitError        # 429 Too Many Requests
```

### Catching errors

```ruby
begin
  client.admin.users.get('nonexistent-uuid')
rescue Hanko::NotFoundError => e
  puts "User not found (HTTP #{e.status})"
rescue Hanko::RateLimitError => e
  puts "Rate limited. Retry after #{e.retry_after} seconds"
rescue Hanko::AuthenticationError
  puts "Invalid API key"
rescue Hanko::ApiError => e
  puts "API error: #{e.message} (HTTP #{e.status})"
  puts e.body  # parsed response body
rescue Hanko::Error => e
  puts "Hanko error: #{e.message}"
end
```

## Security

### Algorithm pinning

All JWT verification is pinned to **RS256**. No algorithm negotiation or `none` algorithm is accepted.

### Credential redaction

`Hanko::Client#inspect` and `Hanko::Configuration#inspect` redact the API key, so credentials are never accidentally leaked to logs:

```ruby
client = Hanko::Client.new(api_url: 'https://example.hanko.io', api_key: 'secret')
puts client.inspect
# => #<Hanko::Client api_url="https://example.hanko.io" api_key=[REDACTED]>
```

### JWKS trust

The SDK only fetches JWKS from the configured `api_url` domain. Webhook verification requires an explicit `jwks_url` parameter -- the URL is never inferred from untrusted input.

### Dependency security

- **faraday** (~> 2.0) -- HTTP client with middleware support
- **jwt** (~> 2.7) -- RFC 7519 JWT implementation
- **concurrent-ruby** (~> 1.0) -- thread-safe data structures

## Requirements

- Ruby >= 3.1 (tested on 3.1, 3.2, 3.3, 3.4)
- Rails >= 7.0 (for `hanko-ruby-rails`, tested on 7.0, 7.1, 7.2, 8.0, 8.1)

## Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/my-feature`)
3. Write tests for your changes
4. Ensure all tests pass: `bundle exec rspec` in both `hanko/` and `hanko-rails/`
5. Ensure linting passes: `bundle exec rubocop`
6. Commit your changes (`git commit -m 'Add my feature'`)
7. Push to the branch (`git push origin feature/my-feature`)
8. Open a Pull Request

## License

Released under the [MIT License](LICENSE.txt).
