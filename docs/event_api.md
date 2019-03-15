# RabbitMQ Barong Event API

## Overview of RabbitMQ details

Barong submits all events into three exchanges depending on event category (read next).

The exchange name consists of three parts: 

  1) application name (typically `barong`)

  2) fixed keyword `events`.

  3) category of event, like `system` (generic system event), `model` (the attributes of some record were updated)

The routing key looks like `user.password.reset.token`, `user.created`.
The event name matches the routing key but with event category appended at the beginning, like `system.user.password.reset.token`, `market.user.created`.

## Overview of RabbitMQ message
Each produced message in `Event API` is JWT (complete format).

This is very similar to `Management API`.

The example below demonstrates both generation and verification of JWT:
```ruby
require "jwt-multisig"
require "securerandom"

jwt_payload = {
    iss:   'barong',
    jti:   SecureRandom.uuid,
    iat:   Time.now.to_i,
    exp:   Time.now.to_i + 60,
    event: event_payload
}

    private_key = OpenSSL::PKey.read(Base64.urlsafe_decode64(private_key)
    algorithm   = 'RS256'
    jwt         = JWT::Multisig.generate_jwt jwt_payload, \
      { barong: private_key },
      { barong: algorithm }

   Kernel.puts "GENERATED JWT", jwt.to_json, "\n"
   
   verification_result = JWT::Multisig.verify_jwt jwt.deep_stringify_keys, \
  { barong: public_key }, { verify_iss: true, iss: "barong", verify_jti: true }

  decoded_jwt_payload = verification_result[:payload]

  Kernel.puts "MATCH AFTER VERIFICATION: #{jwt_payload == decoded_jwt_payload}."
```
The RabbitMQ message is stored in JWT field called `event`.

## Overview of Event API message

The typical event looks like (JSON):

```ruby
  event: {
    record: {
      foo: "ID30DD0DD986",
      bar: "example@barong.io",
      baz: "member",
      qux: 0
    },
    name: "model.user.created"
  }
```
The field `event[:name]` contains event name (same as routing key).
The fields `foo`, `bar`, `baz`, `qux` (example) are fields which carry useful information.

# Barong Event API messages

## Format of `model.user.created` event
```ruby
  event: {
    record: {
      uid: "ID30DD0DD986",
      email: "example@barong.io",
      role: "member",
      level: 0,
      otp: false,
      state: "pending",
      created_at: "2019-01-28T08:35:29Z",
      updated_at: "2019-01-28T08:35:29Z"
    },
    name: "model.user.created"
  }
```
| Field      | Description                         |
| ---------- | ----------------------------------- |
| `record`   | Created user up-to-date attributes.  |

## Format of `system.user.email.confirmation.token` event
```ruby
event: {
  user: {
    uid: "ID739065AFD3",
    email: "example@barong.io",
    role: "member",
    level: 0,
    otp: false,
    state: "pending",
    created_at: "2019-01-28T09:03:50Z",
    updated_at: "2019-01-28T09:03:50Z"
  },
  token: "eyJhbGciOiJSUzI1NiJ9.eyJpYXQiOjE1NDg2NjYyMzAsImV4cCI6MTU0ODY3MjIzMCwic3ViIjoiY29uZmlybWF0aW9uIiwiaXNzIjoiYmFyb25nIiwiYXVkIjpbInBlYXRpbyIsImJhcm9uZyJdLCJqdGkiOiI5OWJkNzFkMjU2NTdlMmI1YzI1MCIsImVtYWlsIjoiYWRtaW4xMjNAYmFyb25nLmlvIiwidWlkIjoiSUQ3MzkwNjVBRkQzIn0.OI5tL9kV6cA1JBAy7G5iqd3WplxcB-waHYKFjm83koMEpx2Hlw9fksq5lip5cIHTjR8i3ambFL40OaCwDNc1jAiDsHwuv2nLswgi88_M1G8KVFylboQdtgmH_cZiz-Y-51Fq2oqEID5QyJnsSMSJbfspb6A0JGT_V-SPK4WFZw43F_RKhlZBCrxojljMwd20rGqFPYirMgUpsfiW0_-mESXzQ7UK1eA8mYO7Id4y6JR2Yoo-JTloEnBL1M189tOz6LqmmQB0M_QjTiHG3y9I97Med3StgVziYo9qog9kJXyPuXbboddg__5WEhMcWbaToohoiT5UvpVJHKfgxEVaDg",
  name: "system.user.email.confirmation.token"
}
```
| Field      | Description                                      |
| ---------- | ------------------------------------------------ |
| `user`   | The up-to-date user attributes.               |
| `token`  | Valid confirm-acc jwt token (mandatory param for user confirmation endpoint) `/identity/users/email/confirm_code` |

 ## Format of `system.user.email.confirmed` event
```ruby
   event: {
    uid: "IDB1629BFE9E",
    email: "example@barong.io",
    role: "member",
    level: 0,
    otp: false,
    state: "active",
    created_at: "2019-01-28T10:17:27Z",
    updated_at: "2019-01-28T10:17:45Z",
    name: "system.user.email.confirmed"
  }
```

## Format of `system.user.password.reset.token` event
```ruby
  event: {
    user: {
      uid: "ID30DD0DD986",
      email: "example@barong.io",
      role: "member",
      level: 0,
      otp: false,
      state: "pending",
      created_at: "2019-01-28T08:35:29Z",
      updated_at: "2019-01-28T08:35:29Z"
    },
    token: "eyJhbGciOiJSUzI1NiJ9.eyJpYXQiOjE1NDg2NjQ1OTUsImV4cCI6MTU0ODY3MDU5NSwic3ViIjoicmVzZXQiLCJpc3MiOiJiYXJvbmciLCJhdWQiOlsicGVhdGlvIiwiYmFyb25nIl0sImp0aSI6IjRhY2IzM2IzYmE2NDc0ZjY1YTI5IiwiZW1haWwiOiJhZG1pbjEyQGJhcm9uZy5pbyIsInVpZCI6IklEMzBERDBERDk4NiJ9.Rie4LCbkV0jVBbhMoceYx8a9uDA-ea9D1v790zlIqP_EY8Iue_OOKXYWiC1Y-55MPicFbknBILjZlPewvAF8ZrhqIt04ROsgBdDGEUGY_SnLWhXzqSx9-v_o_w2MVjLOUxvRBm6sD0RvL-_5LmOcLqhYtf7ZPUnPDwsvhDedqDfbXPEvI7OK2SZ-1uPAOg1IMOX1k7xaDt5I1Wp-Knr2DmEgwNYbIjaXraComYcMdtVSuYVJAufgA0kTADMeT3cV3jzGy9dNfs8heMCtf5tr72IbL0_N0VeUQj9uaPDUr4ntsYk7gOPmA3RSVrSismtYdBXA9oLA0b0YfOctiY9dqg",
    name: "system.user.password.reset.token"
  }
```
| Field      | Description                                      |
| ---------- | ------------------------------------------------ |
| `user`   | The up-to-date user attributes.               |
| `token`  | Valid reset-pass jwt token (mandatory param for password reset endpoint) `/identity/users/password/confirm_code` |

## Format of `system.user.account.discarded` event
```ruby
   event: {
    uid: "IDB1629BFE9E",
    email: "example@barong.io",
    role: "member",
    level: 1,
    otp: false,
    state: "discarded",
    created_at: "2019-01-28T10:17:27Z",
    updated_at: "2019-01-28T10:17:45Z",
    name: "system.user.account.discarded"
  }
```

## Format of `system.user.password.reset` event
```ruby
  event: {
    uid: "ID30DD0DD986",
    email: "example@barong.io",
    role: "member",
    level: 0,
    otp: false,
    state: "pending",
    created_at: "2019-01-28T08:35:29Z",
    updated_at: "2019-01-28T09:42:36Z",
    name: "system.user.password.reset"
  }
```
| Field      | Description                                      |
| ---------- | ------------------------------------------------ |
| `event`   | Contains all up-to-date user info and routing key |

## Format of `system.user.password.change` event
```ruby
  event: {
    uid: "IDC554ED1D0F",
    email: "example@barong.io",
    role: "member",
    level: 0,
    otp: false,
    state: "active",
    created_at: "2019-01-09T15:54:56Z",
    updated_at: "2019-01-28T09:59:03Z",
    name: "system.user.password.change"
  }
 ```
 | Field      | Description                                      |
| ---------- | ------------------------------------------------ |
| `event`   | Contains all up-to-date user info and routing key |

## Format of `system.document.verified` event
```ruby
  event: {
    uid: "IDC554ED1D0F",
    email: "example@barong.io",
    name: "system.document.verified"
  }
 ```
 
 ## Format of `system.document.rejected` event
```ruby
  event: {
    uid: "IDC554ED1D0F",
    email: "example@barong.io",
    name: "system.document.rejected"
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
      record: {
        uid: "ID30DD0DD986",
        email: "example@barong.io",
        role: "member",
        level: 0,
        otp: false,
        state: "pending",
        created_at: "2019-01-28T08:35:29Z",
        updated_at: "2019-01-28T08:35:29Z"
      },
    name: "model.user.created"
  }
  }
  exchange.publish(generate_jwt(jwt_payload), routing_key: "user.created")
end
```

IMPORTANT: Don't forget to implement the logic for JWT exception handling!

## Producing events using `rabbitmqadmin`

`rabbitmqadmin publish routing_key=user.created payload=JWT exchange=barong.events.model`

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
                    .bind(exchange, routing_key: "user.created")
  queue.subscribe manual_ack: true, block: true do |delivery_info, metadata, payload|
    Kernel.puts verify_jwt(JSON.parse(payload)).fetch(:event)
    channel.ack(delivery_info.delivery_tag)
  rescue => e
    channel.nack(delivery_info.delivery_tag, false, true)
  end
end
```

IMPORTANT: Don't forget to implement the logic for JWT exception handling!
