# `DRAFT` RabbitMQ Peatio Event API

## Overview of RabbitMQ details

Peatio submits all events into single exchange called `peatio.events`.

The routing key (same as event name) consists of two parts: 

  1) category of events or subject, like `deposit`, `withdraw`, `system`.

  2) event name, like `created`, `updated`, `destroyed`, `low_hot_wallet_balance`.

## Overview of RabbitMQ message

Each produced message in `Event API` is JWT (complete format).

This is very similar to `Management API`.

The example below demonstrates both generation and verification of JWT:

```ruby
require "jwt-multisig"
require "securerandom"

jwt_payload = {
  iss:  "peatio",
  jti:  SecureRandom.uuid,
  iat:  Time.now.to_i,
  exp:  Time.now.to_i + 60,
  data: {}
}

require "openssl"
private_key = OpenSSL::PKey::RSA.generate(2048)
public_key  = private_key.public_key

generated_jwt = JWT::Multisig.generate_jwt(jwt_payload, { peatio: private_key }, { peatio: "RS256" })

Kernel.puts "GENERATED JWT", generated_jwt.to_json, "\n"

verification_result = JWT::Multisig.verify_jwt generated_jwt.deep_stringify_keys, \
  { peatio: public_key }, { verify_iss: true, iss: "peatio", verify_jti: true }

decoded_jwt_payload = verification_result[:payload]

Kernel.puts "MATCH AFTER VERIFICATION: #{jwt_payload == decoded_jwt_payload}."
```

The RabbitMQ message is stored in JWT field called `data`.

## Overview of Event API message

The typical event looks like (JSON):

```ruby
event: {
  name: "deposit.updated",
  foo:  "...",
  bar:  "...",
  qux:  "..."
}
```

The field `event[:name]` contains event name (same as routing key).
The fields `foo`, `bar`, `qux` (just for example) are fields which carry useful information.

## Format of `deposit.created` event

```ruby
event: {
  name: "deposit.created",
  record: {
    tid:                      "TID9493F6CD41",
    uid:                      "ID092B2AF8E87",
    currency:                 "btc",
    amount:                   "0.0855",
    state:                    "submitted",
    created_at:               "2018-04-12T17:16:06+03:00",
    updated_at:               "2018-04-12T17:16:06+03:00",
    completed_at:             nil,
    blockchain_address:       "n1Ytj6Hy57YpfueA2vtmnwJQs583bpYn7W",
    blockchain_txid:          "c37ae1677c4c989dbde9ac22be1f3ff3ac67ed24732a9fa8c9258fdff0232d72",
    blockchain_confirmations: 1
  }
}
```

| Field      | Description                         |
| ---------- | ----------------------------------- |
| `record`   | The up-to-date deposit attributes.  |

## Format of `deposit.updated` event

```ruby
event: {
  name: "deposit.updated",
  record: {
    tid:                      "TID9493F6CD41",
    uid:                      "ID092B2AF8E87",
    currency:                 "btc",
    amount:                   "0.0855",
    state:                    "accepted",
    created_at:               "2018-04-12T17:16:06+03:00",
    updated_at:               "2018-04-12T18:46:57+03:00",
    completed_at:             "2018-04-12T18:46:57+03:00",
    blockchain_address:       "n1Ytj6Hy57YpfueA2vtmnwJQs583bpYn7W",
    blockchain_txid:          "c37ae1677c4c989dbde9ac22be1f3ff3ac67ed24732a9fa8c9258fdff0232d72",
    blockchain_confirmations: 7
  },
  changes: {
    state:                    "submitted",
    completed_at:             nil,
    blockchain_confirmations: 1,
    updated_at:               "2018-04-12T17:16:06+03:00"
  }
}
```

| Field      | Description                                      |
| ---------- | ------------------------------------------------ |
| `record`   | The up-to-date deposit attributes.               |
| `changes`  | The changed deposit attributes and their values. |

## Format of `withdraw.created` event

```ruby
event: {
  name: "withdraw.created",
  record: {
    tid:             "TID892F29F094",
    uid:             "ID092B2AF8E87",
    rid:             "0xdA35deE8EDDeAA556e4c26268463e26FB91ff74f",
    currency:        "eth",
    amount:          "4.5485",
    fee:             "0.0015",
    state:           "prepared",
    created_at:      "2018-04-12T18:52:16+03:00",
    updated_at:      "2018-04-12T18:52:16+03:00",
    completed_at:    nil,
    blockchain_txid: nil
  }
}
```

| Field      | Description                          |
| ---------- | ------------------------------------ |
| `record`   | The up-to-date withdraw attributes.  |

## Format of `withdraw.updated` event

```ruby
event: {
  name: "withdraw.updated",
  record: {
    tid:             "TID892F29F094",
    uid:             "ID092B2AF8E87",
    rid:             "0xdA35deE8EDDeAA556e4c26268463e26FB91ff74f",
    currency:        "eth",
    amount:          "4.5485",
    fee:             "0.0015",
    state:           "succeed",
    created_at:      "2018-04-12T18:52:16+03:00",
    updated_at:      "2018-04-12T18:56:23+03:00",
    completed_at:    "2018-04-12T18:56:23+03:00",
    blockchain_txid: "0x9c34d1750e225a95938f9884e857ab6f55eedda43b159d13abf773fe6a916164"
  },
  changes: {
    state:           "processing",
    updated_at:      "2018-04-12T18:55:39+03:00",
    completed_at:    "2018-04-12T18:55:39+03:00",
    blockchain_txid: nil
  }
}
```

| Field      | Description                                      |
| ---------- | ------------------------------------------------ |
| `record`   | The up-to-date withdraw attributes.               |
| `changes`  | The changed withdraw attributes and their values. |

## Producing events using Ruby

```ruby
require "bunny"

def generate_jwt(jwt_payload)
  Kernel.abort "Please, see «Overview of RabbitMQ message» for implementation guide."
end

Bunny.run host: "localhost", port: 5672, username: "guest", password: "guest" do |session|
  channel     = session.channel
  exchange    = channel.direct("peatio.events")
  jwt_payload = {
    iss:  "peatio",
    jti:  SecureRandom.uuid,
    iat:  Time.now.to_i,
    exp:  Time.now.to_i + 60,
    data: {
      event: {
        name: "deposit.created",
        record: {
          tid:                      "TID9493F6CD41",
          uid:                      "ID092B2AF8E87",
          currency:                 "btc",
          amount:                   "0.0855",
          state:                    "submitted",
          created_at:               "2018-04-12T17:16:06+03:00",
          updated_at:               "2018-04-12T17:16:06+03:00",
          completed_at:             nil,
          blockchain_address:       "n1Ytj6Hy57YpfueA2vtmnwJQs583bpYn7W",
          blockchain_txid:          "c37ae1677c4c989dbde9ac22be1f3ff3ac67ed24732a9fa8c9258fdff0232d72",
          blockchain_confirmations: 1
        }      
      }
    }  
  }
  exchange.publish(generate_jwt(jwt_payload), routing_key: "deposit.created")
end
```

IMPORTANT: Don't forget to implement the logic for JWT exception handling!

## Producing events using `rabbitmqadmin`

`rabbitmqadmin publish routing_key=deposit.created payload=JWT exchange=peatio.events`

Don't forget to pass environment variable `JWT`.

## Consuming events using Ruby

```ruby
require "bunny"

def verify_jwt(jwt_payload)
  Kernel.abort "Please, see «Overview of RabbitMQ message» for implementation guide."
end

Bunny.run host: "localhost", port: 5672, username: "guest", password: "guest" do |session|
  channel  = session.channel
  exchange = channel.direct("peatio.events")
  queue    = channel.queue("", auto_delete: true, durable: true, exclusive: true)
                    .bind(exchange, routing_key: "deposit.update")
  queue.subscribe manual_ack: true, block: true do |delivery_info, metadata, payload|
    Kernel.puts verify_jwt(JSON.parse(payload)).fetch(:data)
    channel.ack(delivery_info.delivery_tag)
  rescue => e
    channel.nack(delivery_info.delivery_tag, false, true)
  end
end
```

IMPORTANT: Don't forget to implement the logic for JWT exception handling!

