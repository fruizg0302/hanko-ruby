# hanko-ruby

[![CI](https://github.com/fruizg0302/hanko-ruby/actions/workflows/ci.yml/badge.svg)](https://github.com/fruizg0302/hanko-ruby/actions)
[![Gem Version](https://badge.fury.io/rb/hanko-ruby.svg)](https://rubygems.org/gems/hanko-ruby)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

Framework-agnostic Ruby SDK for the [Hanko](https://www.hanko.io/) authentication platform. Verify sessions, manage users via the Admin API, drive login/registration flows, and handle webhooks.

> **Looking for Rails integration?** See [hanko-rails](https://rubygems.org/gems/hanko-rails) for middleware, controller helpers, and generators.

## Installation

```ruby
# Gemfile
gem 'hanko-ruby'
```

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
  config.logger         = Logger.new($stdout)
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
user_ctx.emails.make_primary('email-uuid')
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
```

## Testing

The test helper is **opt-in** — require it explicitly:

```ruby
require 'hanko/test_helper'
```

### Available helpers

```ruby
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

## Error Handling

All errors inherit from `Hanko::Error`:

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
rescue Hanko::Error => e
  puts "Hanko error: #{e.message}"
end
```

## Security

- **Algorithm pinning** — All JWT verification is pinned to RS256. No algorithm negotiation or `none` algorithm is accepted.
- **Credential redaction** — `Hanko::Client#inspect` and `Hanko::Configuration#inspect` redact the API key so credentials are never leaked to logs.
- **JWKS trust** — The SDK only fetches JWKS from the configured `api_url` domain. Webhook verification requires an explicit `jwks_url` parameter.

## Requirements

- Ruby >= 3.1

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
