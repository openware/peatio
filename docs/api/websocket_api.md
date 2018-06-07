# Peatio WebSocket API

## API Documentation

On websocket connection client get `challenge`.

 Then client should authenticate.

### Authentication

Authentication happens on websocket message with following JSON structure.

```JSON
{
  "jwt": "TokenType Token"
}
```

If authenticaton was done, server will respond successfully

```
message: 'Authenticated.'
```

Otherwise server will throw an error

```
message: 'Authentication failed.'
```

If authentication JWT token has invalid type, server throw an error

```
Token type is not provided or invalid.
```

If other error occured during the message handling server throws an error

```
Error while handling message.
```

**Note:** Peatio websocket API supports authentication only with Bearer type of JWT token.

**Example** of authentication message:

```JSON
{
  "jwt": "Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxMjM0NTY3ODkwIiwibmFtZSI6IkpvaG4gRG9lIiwiYWRtaW4iOnRydWV9.TJVA95OrM7E2cBab30RMHrHDcEfxjoYZgeFONFh7HgQ"
}
```

### After authentication

Servers subsribes client to orders and trades of authenticated user.

When order or trade happend websocket server send message to client with object details.

Depending on what trade happend server will send the `ask` and `bid` details.

List of subscription channels:

- Inforamtion about **orders** send to `orderbook` AMQP channel.
- Inforamtion about **trades** send to `trade` AMQP channel.

#### Order

API overview:

| Field           | Description                                |
|-----------------|--------------------------------------------|
| `id`            | Unique order id.                           |
| `side`          | Either `sell` or `buy`.                    |
| `ord_type`      | Type of order, either `limit` or `market`. |
| `price`         | Price for each unit.                       |
| `avg_price`     | Average execution price.                   |
| `state`         | One of `wait`, `done`, or `cancel`.        |
| `market_id`     | The market in which the order is placed.   |
| `created_at`    | Order create time in `iso8601` format.     |
| `origin_volume` | The amount user want to sell/buy.          |
| `trades_count`  | Number of trades.                          |
| `trades`        | List of trades.                            |

#### Trade

Trade API overview:

| Field        | Description                              |
|--------------|----------------------------------------- |
| `id`         | Uniq trade id.                           |
| `price`      | Price for each unit.                     |
| `volume`     | The amount of trade.                     |
| `funds`      |                                          |
| `market_id`  | The market in which the order is placed. |
| `created_at` | Uniq trade id.                           |
| `side`       | Type of order, either `bid` or `ask`.    |
| `order_id`   | Order that placed.                       |
| `bid`        | Bid order object.                        |
| `ask`        | Ask order object.                        |

## Start websocket API

How to running Web Socket API service?
For running Web Socket API service, you need configure and start websocket_api daemon.

Configurations are stored at application.yml under WebSocket Streaming API settings section.

You can start websocket API locally using peatio git repository.

You should have `redis` and `rabbitmq` servers up and running
By default peatio websocket API running on the host `0.0.0.0` and port `8080`

Change host and port by setting environment variables

```yaml
WEBSOCKET_HOST: 0.0.0.0
WEBSOCKET_PORT: 8080
```

Start websocket daemon

```sh
$ bundle exec ruby lib/daemons/websocket_api.rb
```
