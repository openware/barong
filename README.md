![Cryptocurrency Exchange Platform - Barong](https://github.com/openware/meta/raw/main/images/github_barong.png)

<h3 align="center">
<a href="https://www.openware.com/sdk">Guide</a> <span>&vert;</span>
<a href="https://www.openware.com/sdk/api/barong/rest-api.html">API Docs</a> <span>&vert;</span>
<a href="https://www.openware.com/">Consulting</a> <span>&vert;</span>
<a href="https://t.me/peatio">Community</a>
</h3>
<h6 align="center">Component part of <a href="https://github.com/openware/opendax">OpenDAX Trading Platform</a></h6>

# Barong
![Build Status](https://travis-ci.org/rubykube/barong.svg?branch=master)
![Maintainability](https://api.codeclimate.com/v1/badges/a53414f061e69f6f531a/maintainability)

# Overview

Barong is oAuth server for [Openware.com][openware.com] stack.

# Development

Prerequisites:
- Ruby version: `2.5.3`
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

4. Install JS dependencies
```
yarn install
```

5. Start local server
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
[Barong environments overview](https://github.com/openware/barong/blob/master/docs/configuration.md#barong-environments-overview)

[Barong configurations overview](https://github.com/openware/barong/blob/master/docs/configuration.md#barong-configurations-overview)

[Troubleshooting](https://github.com/openware/barong/blob/master/docs/troubleshooting.md)

[REST API documentation](https://github.com/openware/barong/blob/master/docs/api/rest_api.md)

[API Keys creation and usage](https://github.com/openware/barong/blob/master/docs/general/api-keys.md)

[Captcha policy overview and configuration](https://github.com/openware/barong/blob/master/docs/general/captcha.md)

[Setting up 2FA](https://github.com/openware/barong/blob/master/docs/general/2fa.md)

[Barong password hashing](https://github.com/openware/barong/blob/master/docs/general/password_hashing.md#barong-password-hashing)


# License
Barong is released under the terms of the [Apache License 2.0](./LICENSE.md).
