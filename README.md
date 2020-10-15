[travis]: https://travis-ci.org/rubykube/barong
[codeclimate]: https://codeclimate.com/github/rubykube/barong/maintainability
[openware.com]: https://www.openware.com

# Barong
[![Build Status](https://travis-ci.org/rubykube/barong.svg?branch=master)][travis]
[![Maintainability](https://api.codeclimate.com/v1/badges/a53414f061e69f6f531a/maintainability)][codeclimate]

# Overview

Barong is a authentication service for microservice architectures using JWT standard.

It includes the following features:

- Registration of users
- Role based access control (RBAC)
- Embedded KyC process
- Integrated [KycAID](https://www.openware.com/sdk/docs/barong/kycaid.html) plugin
- Mailing system: event based, support multi-language, secured by cryptographic signatures
- [Service accounts](https://www.openware.com/sdk/docs/barong/service-accounts.html)
- Focused on user privacy: sensitive informations are encrypted in database using vault, masks are applied on fields in user API endpoints

Made with :love: by [Openware][https://www.openware.com].

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
```

4. Start local server
```
bundle exec rails server
```

# Barong Levels

In the process of verification Barong assign different levels to accounts

- Level 0 is default account level
- Level 1 will apply after email verification
- Level 2 will apply after phone verification
- Level 3 will apply after identity & document verification

# Useful links to documentation
[Barong configuration](https://www.openware.com/sdk/docs/barong/configuration.html)

[Troubleshooting](https://www.openware.com/sdk/docs/barong/troubleshooting.html)

[REST API documentation](https://www.openware.com/sdk/docs/barong/rest-api.html)

[API Keys creation and usage](https://www.openware.com/sdk/docs/barong/general/api-keys.html)

[Captcha policy overview and configuration](https://www.openware.com/sdk/docs/barong/general/captcha.html)

[Setting up 2FA](https://www.openware.com/sdk/docs/barong/2fa.html)

[Barong password hashing](https://www.openware.com/sdk/docs/barong/general/password-hashing.html)

[Barong data encryption](https://www.openware.com/sdk/docs/barong/general/encryption.html)

# License
Barong is released under the terms of the [Apache License 2.0](https://github.com/openware/barong/blob/master/LICENSE.md).
