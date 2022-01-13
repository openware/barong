[openware.com]: https://www.openware.com

# Barong
[![Build Status](https://ci.openware.work/api/badges/openware/barong/status.svg)](https://ci.openware.work/openware/barong)

Barong is a authentication service for microservice architectures using JWT standard.
It's developped and maintained by [Openware](https://www.openware.com) team.

- [Barong](#barong)
- [Overview](#overview)
- [Development](#development)
- [Update grape_routes](#update-grape_routes)
- [Deploy with capistrano](#deploy-with-capistrano)
  - [Deploy mailer only](#deploy-mailer-only)
- [Environment variables](#environment-variables)
- [Barong Levels](#barong-levels)
- [Useful links to documentation](#useful-links-to-documentation)
- [License](#license)

# Overview

It includes the following features:

- Registration of users
- Role based access control (RBAC)
- Embedded KyC process
- Integrated [KycAID](https://www.openware.com/sdk/docs/barong/kycaid.html) plugin
- Mailing system: event based, support multi-language, secured by cryptographic signatures
- [Service accounts](https://www.openware.com/sdk/docs/barong/service-accounts.html)
- Focused on user privacy: sensitive informations are encrypted in database using vault, masks are applied on fields in user API endpoints


# Development

Prerequisites:
- Ruby version: `2.6.6`
- Bundler preinstalled
- MySQL preinstalled

1. Install RubyGems dependencies
```
bundle install
```

2. Copy initialisation files
```
bin/init_config
```

3. Create database and run migrations
```
bundle exec rake db:create db:migrate
DB=bitzlato bundle exec rake db:create db:migrate
```

4. Start local server
```
bundle exec rails server
```

## Update grape_routes

```
bundle exec rails grape:save_routes
```

# Testing

```
VAULT_TOKEN=changeme docker-compose up
./bin/vault
bundle exec rspec
```

# Deploy with capistrano

First time deploy

```
bundle exec cap production deploy:check:directories puma:config systemd:puma:setup systemd:mailer:setup
```

## Deploy mailer only

```
SERVER=$MAILER_SERVER cap production deploy
```
# Environment variables
<details>
  <summary>Variables list</summary>

- **BARONG_REDIS_URL** - *url of redis server with port (example: 'redis://localhost:6379/1')*
- **BITZLATO_DATABASE_URL** - *(example: postgres://dbuser:dbpass@serverip:5432/dbname?pool=poolsize)*
- **BUGSNAG_API_KEY** - *Notifier API key from [bugsnag](https://www.bugsnag.com) (example: QWE1234567890)*
- **COOKIE_DOMAIN** - *Common domain for auth (example: .domain.com)*
- **DATABASE_COLLATION** - *(example: )*
- **DATABASE_HOST** - *(example: 192.168.1.1)*
- **DATABASE_NAME** - *(example: postgres)*
- **DATABASE_PASS** - *(example: postgres)*
- **DATABASE_PORT** - *(example: postgres)*
- **DATABASE_USER** - *(example: postgres)*
- **DIRECT_AUTH** - *(example: )*
- **DIRECT_SESSION_ACCESS** - *(example: )*
- **EVENT_API_RABBITMQ_URL** - *[Rabbit](https://www.rabbitmq.com/uri-spec.html) connection string (example: amqp://user:pass@host:10000/vhost)*
- **JWT_PRIVATE_KEY** - *[JWT](https://jwt.io/introduction)*
- **JWT_PRIVATE_KEY_PATH** - *[JWT](https://jwt.io/introduction)*
- **JWT_PUBLIC_KEY** - *[JWT](https://jwt.io/introduction)*
- **PEATIO_JWT_PUBLIC_KEY** - *[JWT](https://jwt.io/introduction)*
- **PORT** - *Specifies the port that Puma will listen on to receive requests (example: 3000)*
- **RAILS_MASTER_KEY** - *Master key (example: )*
- **RAILS_MAX_THREADS** - *Maximum number of threads for Puma (example: 5)*
- **RAILS_MIN_THREADS** - *Minimum number of threads for Puma (example: 1)*
- **RAILS_SERVE_STATIC_FILES** - *Set to serve static files from the /public folder (example: enabled)*
- **SECRET_KEY_BASE** - *[Key for encryption](https://github.com/openware/barong/pull/1150) on profile, phone and document models*
- **SESSION_KEY** - 
- **SESSION_SECRET** - *Something for Redis*
- **SKIP_SESSION_INVALIDATION** - *(example: )*
- **SLACKISTRANO_CHANNEL** - *[Slack](https://www.rubydoc.info/gems/slackistrano) channel to send deploy notification*
- **SLACKISTRANO_WEBHOOK** - *[Slack](https://www.rubydoc.info/gems/slackistrano) webhook to send deploy notification*
- **USE_BITZLATO_AUTHORIZATION** - 
- **VAULT_ENABLED** - *Set Barong to encrypt data with [Vault](https://www.vaultproject.io) (example: true)*
- **WEB_CONCURRENCY** - *Number of worker processes(example: 3)*
</details>

# Barong Levels

In the process of verification Barong assign different levels to accounts

- Level 0 is default account level
- Level 1 will apply after email verification
- Level 2 will apply after phone verification
- Level 3 will apply after identity & document verification

# Useful links to documentation
[Barong configuration](https://www.openware.com/sdk/docs/barong/configuration.html)

[Troubleshooting](https://www.openware.com/sdk/docs/barong/troubleshooting.html)

[REST Admin API documentation](https://www.openware.com/sdk/docs/barong/api/barong-admin-api-v2.html)

[REST Management API documentation](https://www.openware.com/sdk/docs/barong/api/barong-management-api-v2.html)

[REST User API documentation](https://www.openware.com/sdk/docs/barong/api/barong-user-api-v2.html)

[API Keys creation and usage](https://www.openware.com/sdk/docs/barong/general/api-keys.html)

[Captcha policy overview and configuration](https://www.openware.com/sdk/docs/barong/general/captcha.html)

[Setting up 2FA](https://www.openware.com/sdk/docs/barong/general/2fa.html)

[Barong password hashing](https://www.openware.com/sdk/docs/barong/general/password-hashing.html)

[Barong data encryption](https://www.openware.com/sdk/docs/barong/general/encryption.html)

# License
Barong is released under the terms of the [Apache License 2.0](https://github.com/openware/barong/blob/master/LICENSE.md).
