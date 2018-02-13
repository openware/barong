[travis]: https://travis-ci.org/rubykube/barong
[codeclimate]: https://codeclimate.com/github/rubykube/barong/maintainability

# Barong
[![Build Status](https://travis-ci.org/rubykube/barong.svg?branch=master)][travis]
[![Maintainability](https://api.codeclimate.com/v1/badges/a53414f061e69f6f531a/maintainability)][codeclimate]

# Overview

Barong is oAuth server for [peatio.tech](https://www.peatio.tech) stack.

# Development

Prerequisites:
- Ruby version: `2.5.0`
- Bundler preinstalled
- MySQL preinstalled

1. Install RubyGems dependencies
```
bundle install
```

2. Create database and run migrations
```
bundle exec rake db:create db:migrate
```

3. Start local server
```
bundle exec rails server
```

# License
Barong is released under the terms of the [Apache License 2.0](./LICENSE.md).
