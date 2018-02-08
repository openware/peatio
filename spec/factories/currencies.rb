FactoryBot.define do
  factory :currency do
    hot_wallet_address 'unknown'

    factory :currency_usd do
      key    'dollar'
      code   'USD'
      name   'American Dollar'
      symbol '$'
      type   'fiat'
      quick_withdraw_limit 10
      visible true
    end

    factory :currency_btc do
      key 'satoshi'
      code 'BTC'
      name 'Bitcoin'
      symbol '฿'
      type   'coin'
      base_factor 100_000_000
      api_client 'BTC'
      quick_withdraw_limit 11
      json_rpc_endpoint 'http://bitcoinrpc:5gKAgrJv8CQr2CGUhjVbBFLSj29HnE6YGXvfykHJzS3k@127.0.0.1:18332'
      hot_wallet_address 'unknown'
      wallet_url_template 'https://blockchain.info/address/#{address}'
      transaction_url_template 'https://blockchain.info/tx/#{txid}'
      options { {
        bitgo_test_net:              true,
        bitgo_wallet_id:             nil,
        bitgo_wallet_address:        nil,
        bitgo_wallet_passphrase:     nil,
        bitgo_rest_api_root:         'https://test.bitgo.com/api/v2',
        bitgo_rest_api_access_token: nil
      } }
    end

    factory :currency_bts do
      key 'protoshare'
      code 'BTS'
      symbol 'B'
      name 'BitShares'
    end

  end
end
