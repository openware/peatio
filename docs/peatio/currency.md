## Coin currency
Add currency record to config/currencies.yml

e.g. add litecoin currency 

### add currency config to `config/currencies.yml`

    - id:                   [uniq number]      
      code:                 ltc
      symbol:               'Ł'
      type:                 coin
      precision:            8
      base_factor:          100_000_000
      visible:              true
      quick_withdraw_limit: 5
      options:
        api_client:                  LTC 
        json_rpc_endpoint:           http://username:password@host:port
        bitgo_test_net:              on
        bitgo_wallet_id:             ~
        bitgo_wallet_address:        ~
        bitgo_wallet_passphrase:     ~
        bitgo_rest_api_root:         https://test.bitgo.com/api/v2
        bitgo_rest_api_access_token: ~
        wallet_url_template:         https://www.blocktrail.com/LTC/address/#{address}
        transaction_url_template:    https://www.blocktrail.com/LTC/tx/#{txid} 