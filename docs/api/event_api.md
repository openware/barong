# RabbitMQ Barong Event API

## Overview of RabbitMQ details

Barong submits all events into two exchanges depending on event category (read next).

The exchange name consists of three parts:

  1) application name, like `barong`.

  2) fixed keyword `events`.

  3) category of event, like `model` (the attributes of some record were updated) and `system`.

The routing key looks like `account.updated`, `profile.created`.
The event name matches the routing key but with event category appended at the beginning, like `model.account.updated`, `model.profile.created`.

## Overview of RabbitMQ message

Each produced message in `Event API` is JWT (complete format).

This is very similar to `Management API`.

The example below demonstrates both generation and verification of JWT:

```ruby
require "jwt-multisig"
require "securerandom"

jwt_payload = {
  iss:   "barong",
  jti:   SecureRandom.uuid,
  iat:   Time.now.to_i,
  exp:   Time.now.to_i + 60,
  event: {}
}

require "openssl"
private_key = OpenSSL::PKey::RSA.generate(2048)
public_key  = private_key.public_key

generated_jwt = JWT::Multisig.generate_jwt(jwt_payload, { barong: private_key }, { barong: "RS256" })

Kernel.puts "GENERATED JWT", generated_jwt.to_json, "\n"

verification_result = JWT::Multisig.verify_jwt generated_jwt.deep_stringify_keys, \
  { barong: public_key }, { verify_iss: true, iss: "barong", verify_jti: true }

decoded_jwt_payload = verification_result[:payload]

Kernel.puts "MATCH AFTER VERIFICATION: #{jwt_payload == decoded_jwt_payload}."
```

The RabbitMQ message is stored in JWT field called `event`.

## Overview of Event API message

The typical event looks like (JSON):

```ruby
event: {
  name: "model.account.updated",
  foo:  "...",
  bar:  "...",
  qux:  "..."
}
```

The field `event[:name]` contains event name (same as routing key).
The fields `foo`, `bar`, `qux` (just for example) are fields which carry useful information.

## Format of `account.created` event
  (Format of `account.updated` event the same)

```ruby
event: {
  name: "model.account.created",
  record: {
    uid: 'ID092B2AF8E87',
    email: 'email@example.com',
    level: 0,
    otp_enabled: false,
    confirmation_sent_at: '2018-04-12T17:16:06+03:00',
    state: 'pending',
    created_at: '2018-04-12T17:16:06+03:00',
    updated_at: '2018-04-12T17:16:06+03:00'
  }
}
```

| Field      | Description                         |
| ---------- | ----------------------------------- |
| `record`   | The up-to-date account attributes.  |

## Format of `model.account.updated` event

```ruby
event: {
  name: "model.account.updated",
  record: {
    uid: 'ID092B2AF8E87',
    email: 'email@example.com',
    level: 1,
    otp_enabled: false,
    confirmed_at: '2018-04-12T18:16:06+03:00',
    confirmation_sent_at: '2018-04-12T17:16:06+03:00',
    state: 'active',
    created_at: '2018-04-12T17:16:06+03:00',
    updated_at: '2018-04-12T17:16:06+03:00'
  },
  changes: {
    state: "pending",
    updated_at: "2018-04-12T17:16:06+03:00"
  }
}
```

| Field      | Description                                      |
| ---------- | ------------------------------------------------ |
| `record`   | The up-to-date account attributes.               |
| `changes`  | The changed account attributes and their values. |

## Format of `model.profile.created` event

```ruby
event: {
  name: "model.profile.created",
  record: {
    account_uid: "ID092B2AF8E87",
    first_name: "First",
    last_name: "Last",
    dob: "1976-10-12",
    address: "7873 Stoltenberg Well",
    postcode: 12354,
    city: "New Coralie",
    country: "USA",
    metadata: {
      state: 'Texas'
    },
    created_at:      "2018-04-12T18:52:16+03:00",
    updated_at:      "2018-04-12T18:52:16+03:00"
  }
}
```

| Field      | Description                          |
| ---------- | ------------------------------------ |
| `record`   | The up-to-date profile attributes.  |

## Format of `model.profile.updated` event

```ruby
event: {
  name: "model.profile.updated",
  record: {
    account_uid: "ID092B2AF8E87",
    first_name: "First",
    last_name: "Last",
    dob: "1976-10-12",
    address: "7873 Stoltenberg Well",
    postcode: 12354,
    city: "New Coralie",
    country: "USA",
    metadata: {},
    created_at:      "2018-04-12T18:52:16+03:00",
    updated_at:      "2018-04-12T18:52:16+03:00"
  },
  changes: {
    city: "Coralie",
    updated_at:      "2018-04-12T18:55:39+03:00",
  }
}
```

| Field      | Description                                      |
| ---------- | ------------------------------------------------ |
| `record`   | The up-to-date profile attributes.               |
| `changes`  | The changed profile attributes and their values. |

## Format of `system.document.verified` event

```ruby
event: {
  name: "system.document.verified",
  uid: "ID092B2AF8E87",
  email: "email@example.com"
}
```

## Format of `system.document.rejected` event

```ruby
event: {
  name: "system.document.rejected",
  uid: "ID092B2AF8E87",
  email: "email@example.com"
}
```

## Format of `system.account.reset_password_token` event

```ruby
event: {
  name: "system.account.reset_password_token",
  uid: "ID092B2AF8E87",
  email: "email@example.com",
  token: "token"
}
```

## Format of `system.account.unlock_token` event

```ruby
event: {
  name: "system.account.unlock_token",
  uid: "ID092B2AF8E87",
  email: "email@example.com",
  token: "token"
}
```

## Producing events using Ruby

```ruby
require "bunny"

def generate_jwt(jwt_payload)
  Kernel.abort "Please, see «Overview of RabbitMQ message» for implementation guide."
end

Bunny.run host: "localhost", port: 5672, username: "guest", password: "guest" do |session|
  channel     = session.channel
  exchange    = channel.direct("barong.events.model")
  jwt_payload = {
    iss:   "barong",
    jti:   SecureRandom.uuid,
    iat:   Time.now.to_i,
    exp:   Time.now.to_i + 60,
    event: {
      name: "model.account.created",
      record: {
        uid: 'ID092B2AF8E87',
        email: 'email@example.com',
        level: 0,
        otp_enabled: false,
        confirmation_token: 'n1Ytj6Hy57YpfueA2vtmnwJQs583bpYn7Wsfr',
        confirmation_sent_at: '2018-04-12T17:16:06+03:00',
        state: 'pending',
        created_at: '2018-04-12T17:16:06+03:00',
        updated_at: '2018-04-12T17:16:06+03:00'
      }
    }
  }
  exchange.publish(generate_jwt(jwt_payload), routing_key: "")
end
```

IMPORTANT: Don't forget to implement the logic for JWT exception handling!

## Producing events using `rabbitmqadmin`

`rabbitmqadmin publish routing_key=account.created payload=JWT exchange=barong.events.model`

Don't forget to pass environment variable `JWT`.

## Consuming events using Ruby

```ruby
require "bunny"

def verify_jwt(jwt_payload)
  Kernel.abort "Please, see «Overview of RabbitMQ message» for implementation guide."
end

Bunny.run host: "localhost", port: 5672, username: "guest", password: "guest" do |session|
  channel  = session.channel
  exchange = channel.direct("barong.events.model")
  queue    = channel.queue("", auto_delete: true, durable: true, exclusive: true)
                    .bind(exchange, routing_key: "account.updated")
  queue.subscribe manual_ack: true, block: true do |delivery_info, metadata, payload|
    Kernel.puts verify_jwt(JSON.parse(payload)).fetch(:event)
    channel.ack(delivery_info.delivery_tag)
  rescue => e
    channel.nack(delivery_info.delivery_tag, false, true)
  end
end
```

IMPORTANT: Don't forget to implement the logic for JWT exception handling!
