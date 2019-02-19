# Peatio Member API Errors

## /account

| Code                                    | Description                                    |
| --------------------------------------- | ---------------------------------------------- |
| `account.currency.doesnt_exist`         | **Currency** doesn't exist in database         |
| `account.deposit.invalid_state`         | Deposit **state** is not valid                 |
| `account.deposit.non_integer_limit`     | Parameter **limit** should be integer type     |
| `account.deposit.invalid_limit`         | Parameter **limit** is not valid               |
| `account.deposit.non_positive_page`     | Parameter **page** should be positive number   |
| `account.deposit.empty_txid`            | Parameter **txid** is missing or empty         |
| `account.withdraw.non_integer_limit`    | Parameter **limit** should be integer type     |
| `account.withdraw.invalid_limit`        | Parameter **limit** is not valid               |
| `account.withdraw.non_positive_page`    | Parameter **page** should be positive number   |
| `account.withdraw.non_integer_otp`      | Parameter **otp** should be integer type       |
| `account.withdraw.empty_otp`            | Parameter **otp** is missing or empty          |
| `account.withdraw.empty_rid`            | Parameter **rid** is missing or empty          |
| `account.withdraw.non_decimal_amount`   | Parameter **amount** should be decimal type    |
| `account.withdraw.non_positive_amount`  | Parameter **amount** should be positive number |
| `account.withdraw.insufficient_balance` | Account balance is insufficient                |
| `account.withdraw.invalid_amount`       | Parameter **amount** is not valid              |
| `account.withdraw.create_error`         | Failed to create withdraw                      |
| `account.withdraw.invalid_otp`          | Parameter **otp** is not valid                 |
| `account.withdraw.disabled_api`         | Withdrawal API is disabled                     |
| `account.deposit.not_permitted`         | Pass the corresponding verification steps to **deposit funds** |
| `account.withdraw.not_permitted`        | Pass the corresponding verification steps to **withdraw funds** |
| `account.deposit_address.invalid_address_format`             | Invalid parameter for deposit address format |
| `account.deposit_address.doesnt_support_cash_address_format` | Currency doesn't support cash address format |

## /market

| Code                                         | Description                                    |
| -------------------------------------------- | ---------------------------------------------- |
| `market.account.insufficient_balance`        | Account balance is insufficient                |
| `market.market.doesnt_exist`                 | **Market** doesn't exist in database           |
| `market.order.insufficient_market_liquidity` | Isufficient market liquidity                   |
| `market.order.invalid_volume_or_price`       | Invalid order **volume** or **price**          |
| `market.order.create_error`                  | Failed to create order                         |
| `market.order.cancel_error`                  | Failed to cancel order                         |
| `market.order.market_order_price`            | Market order doesn't have **price**            |
| `market.order.invalid_state`                 | Parameter **state** is not valid               |
| `market.order.invalid_limit`                 | Parameter **limit** is not valid               |
| `market.order.non_integer_limit`             | Parameter **limit** should be integer type     |
| `market.order.invalid_order_by`              | Parameter **order_by** is not valid            |
| `market.order.invalid_side`                  | Parameter **side** is not valid                |
| `market.order.non_decimal_volume`            | Parameter **volume** should be decimal type    |
| `market.order.non_positive_volume`           | Parameter **volume** should be positive number |
| `market.order.invalid_type`                  | Parameter **type** is not valid                |
| `market.order.non_decimal_price`             | Parameter **price** should be decimal type     |
| `market.order.non_positive_price`            | Parameter **price** should be positive number  |
| `market.order.non_integer_id`                | Parameter **id** should be integer type        |
| `market.order.empty_id`                      | Parameter **id** is missing or empty           |
| `market.trade.non_integer_limit`             | Parameter **limit** should be integer type     |
| `market.trade.invalid_limit`                 | Parameter **limit** is not valid               |
| `market.trade.empty_page`                    | Parameter **page** is missing or empty         |
| `market.trade.non_integer_timestamp`         | Parameter **timestamp** should be integer type |
| `market.trade.empty_timestamp`               | Parameter **timestamp** is missing or empty    |
| `market.trade.invalid_order_by`              | Parameter **order_by** is not valid            |
| `market.trade.not_permitted`                 | Pass the corresponding verification steps to **enable trading** |

## /public

| Code                                      | Description                                             |
| ----------------------------------------- | ------------------------------------------------------- |
| `public.currency.doesnt_exist`            | **Currency** doesn't exist in database                  |
| `public.currency.invalid_type`            | **Currency** type is not valid                          |
| `public.market.doesnt_exist`              | **Market** doesn't exist in database                    |
| `public.order_book.non_integer_ask_limit` | Parameter **ask_limit** should be valud of integer type |
| `public.order_book.invalid_ask_limit`     | Parameter **ask_limit** is not valid                    |
| `public.order_book.non_integer_bid_limit` | Parameter **bid_limit** should be valud of integer type |
| `public.order_book.invalid_bid_limit`     | Parameter **bid_limit** is not valid                    |
| `public.trade.invalid_limit`              | Parameter **limit** is not valid                        |
| `public.trade.non_integer_limit`          | Parameter **limit** should be valud of integer type     |
| `public.trade.non_positive_page`          | Parameter **page** should be positive number            |
| `public.trade.non_integer_timestamp`      | Parameter **timestamp** should be value of integer type |
| `public.trade.invalid_order_by`           | Parameter **order_by** is not valid                     |
| `public.market_depth.non_integer_limit`   | Parameter **limit** should be value of integer type     |
| `public.market_depth.invalid_limit`       | Parameter **limit** is not valid                        |
| `public.k_line.non_integer_period`        | Parameter **period** should be value of integer type    |
| `public.k_line.invalid_period`            | Parameter **period** is not valid                       |
| `public.k_line.non_integer_time_from`     | Parameter **time_from** should be value of integer type |
| `public.k_line.empty_time_from`           | Parameter **time_from** is missing or empty             |
| `public.k_line.non_integer_time_to`       | Parameter **time_to** should be value of integer type   |
| `public.k_line.empty_time_to`             | Parameter **time_to** is missing or empty               |
| `public.k_line.non_integer_limit`         | Parameter **limit** should be value of integer type     |
| `public.k_line.invalid_limit`             | Parameter **limit** is not valid                        |

## Authentication

| Code                    | Description                         |
| ----------------------- | ----------------------------------- |
| `jwt.decode_and_verify` | Impossible to decode and verify JWT |
| `record.not_found`      | Record Not found                    |
| `server.internal_error` | Internal Server Error               |
