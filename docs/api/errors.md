# Peatio Member API errors

## Account module errors
```
account.currency.doesnt_exist                                 Currency doesn't exist in database
account.deposit.invalid_state                                 Deposit invalid state
account.deposit.non_integer_limit                             Limit you submitted could not be parsed into Integer
account.deposit.invalid_limit                                 Limit has invalid value
account.deposit.non_positive_page                             Page must be positive number
account.deposit.empty_txid                                    TXID is empty
account.deposit_address.invalid_address_format                Invalid param for deposit address format

account.deposit_address.doesnt_support_cash_address_format    Currency doesn't support cash address format
account.withdraw.non_integer_limit                            Limit Value you send could not be parsed into Integer type
account.withdraw.invalid_limit                                Invalid limit
account.withdraw.non_positive_page                            Page value must be positive
account.withdraw.non_integer_otp                              Otp value could not be parsed into Integer type
account.withdraw.empty_otp                                    Otp is missing, otp is empty
account.withdraw.empty_rid                                    Rid is missing, rid is empty
account.withdraw.non_decimal_amount                           Amount value you send could not be parsed into Decimal type
account.withdraw.non_positive_amount                          Amount value must be positive
account.currency.doesnt_exist                                 Currency doesn't exist
account.deposit.not_permitted                                 Please, pass the corresponding verification steps to deposit funds
account.withdraw.not_permitted                                Please, pass the corresponding verification steps to withdraw funds
account.withdraw.insufficient_balance                         Account balance is insufficient
account.withdraw.invalid_amount                               Invalid withdraw amount
account.withdraw.create_error                                 Failed to create withdraw
account.withdraw.invalid_otp                                  Invalid otp
account.withdraw.disabled_api                                 Withdrawal API is disabled
```

/market
```
market.market.doesnt_exist                                    Market doesn't exist
market.order.invalid_state                                    Invalid deposit state
market.order.invalid_limit                                    Invalid limit
market.order.non_integer_limit                                Limit value you send could not be parsed into Integer type
market.trade.empty_page                                       Page is missing or empty
market.order.invalid_order_by                                 Invalid order_by
market.order.invalid_side                                     Invalid order side
market.order.non_decimal_volume                               Volume value you send could not be parsed into Decimal type
market.order.non_positive_volume                              Volume value must be positive
market.order.invalid_type                                     Invalid order type
market.order.non_decimal_price                                Volume value you send could not be parsed into Decimal type
market.order.non_positive_price                               Volume value must be positive
market.order.non_integer_id                                   Id value  you send could not be parsed into Integer type
market.order.empty_id                                         Id is missing or empty
market.trade.non_integer_limit                                Limit value you send could not be parsed into Integer type
market.trade.invalid_limit                                    Invalid limit
market.trade.empty_page                                       Page is missing or empty
market.trade.non_integer_timestamp                            Timestamp value you send could not be parsed into Integer type
market.trade.empty_timestamp                                  Timestamp is missing or empty
market.trade.invalid_order_by                                 Invalid order_by
market.order.insufficient_market_liquidity                    Isufficient market liquidity
market.order.invalid_volume_or_price                          Invalid volume or price
market.order.create_error                                     Failed to create error
market.order.cancel_error                                     Failed to cancel error
market.order.market_order_price                               Market order doesn't have price
market.trade.not_permitted                                    Please, pass the corresponding verification steps to enable trading
market.account.insufficient_balance                           Account balance is insufficient
```

/public
```
public.currency.doesnt_exist                                  Currency doesn't exist
public.currency.invalid_type                                  Invalid currency type
public.market.doesnt_exist                                    Market doesn't exist
public.order_book.non_integer_ask_limit                       Ask limit value you send could not be parsed into Integer type
public.order_book.invalid_ask_limit                           Invlalid ask limit
public.order_book.non_integer_bid_limit                       Bid limir value you send could not be parsed into Integer type
public.order_book.invalid_bid_limit                           Invalid bid limit
public.trade.non_integer_limit                                Limit value you send could not be parsed into Integer type
public.trade.invalid_limit                                    Invalid limit
public.trade.non_integer_limit                                Limit value you send could not be parsed into Integer type
public.trade.non_positive_page                                Page value must be positive
public.trade.non_integer_timestamp                            Timestamp value you send could not be parsed into Integer type
public.trade.invalid_order_by                                 Invalid order by
public.market_depth.non_integer_limit                         Limit value you send could not be parsed into Integer type
public.market_depth.invalid_limit                             Invalid limit
public.k_line.non_integer_period                              Limit value you send could not be parsed into Integer type
public.k_line.invalid_period                                  Invalid period
public.k_line.non_integer_time_from                           Limit value you send could not be parsed into Integer type
public.k_line.empty_time_from                                 Time_from param is missing or empty
public.k_line.non_integer_time_to                             Limit value you send could not be parsed into Integer type
public.k_line.empty_time_to                                   Time_to param is missing or empty
public.k_line.non_integer_limit                               Limit value you send could not be parsed into Integer type
public.k_line.invalid_limit                                   Invalid limit
```
auth
```
jwt.decode_and_verify                                         Couldn't decode and verify jwt
record.not_found                                              Record not found
server.internal_error                                         Internal Server Error
```
