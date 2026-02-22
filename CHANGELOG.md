# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.1.0] - 2026-02-22

### Added

#### `hanko-ruby` gem

- `Hanko::Client` with global and per-client configuration
- `Hanko::Configuration` with sensible defaults and credential redaction
- `Hanko::Connection` HTTP layer built on Faraday with automatic error middleware
- `Hanko::Resource` response wrapper with hash-style and method-style access
- Session verification via `Hanko::Api::Public::Sessions` (validate, validate_token)
- Admin API namespace with full CRUD:
  - `Users` with user-scoped sub-resources (`UserContext`)
  - `Emails` (list, create, delete, set_primary)
  - `Passwords` (create, get, update, delete)
  - `Sessions` (list, delete)
  - `WebauthnCredentials` (list, delete)
  - `Metadata` (get, update)
  - `Webhooks` (list, get, create, update, delete)
  - `AuditLogs` (list)
- Public API namespace:
  - `Sessions` (validate, validate_token)
  - `WellKnown` (jwks, config)
  - `Flow` (login, registration, profile) with `FlowResponse` object
- `Hanko::WebhookVerifier` for verifying incoming webhook JWTs (RS256-pinned)
- `Hanko::TestHelper` with token generation, JWKS stubbing, and stub verifier
- Error hierarchy: `Error`, `ConfigurationError`, `InvalidTokenError`, `ExpiredTokenError`, `JwksError`, `ConnectionError`, `ApiError`, `AuthenticationError`, `NotFoundError`, `RateLimitError`
- Thread-safe JWKS cache via `concurrent-ruby`

#### `hanko-rails` gem

- `Hanko::Rails::Engine` for automatic middleware registration
- `Hanko::Rails::Middleware` -- extracts tokens from cookies or `Authorization: Bearer` header, verifies via JWKS, sets `hanko.session` in the Rack env
- `Hanko::Rails::Authentication` controller concern with `hanko_session`, `hanko_user_id`, `hanko_authenticated?`, `current_hanko_user`, and `authenticate_hanko_user!`
- `Hanko::Rails::Configuration` with `cookie_name`, `jwks_cache_ttl`, and `exclude_paths`
- `Hanko::Rails::TestHelper` with `sign_in_as_hanko_user` and `sign_out_hanko_user`
- `Hanko::Rails::Generators::InstallGenerator` (`rails generate hanko:install`)

[0.1.0]: https://github.com/fruizg0302/hanko-ruby/releases/tag/v0.1.0
