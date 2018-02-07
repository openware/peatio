namespace :currencies do
  desc 'Seed currencies'
  task seed: :environment do

    Currency.create!(
      key:    'dollar',
      code:   'USD',
      name:   'American Dollar',
      symbol: '$',
      type:   'fiat',
      json_rpc_endpoint: nil,
      rest_api_endpoint: nil,
      hot_wallet_address: 'unknown',
      quick_withdraw_limit: 10,
      options: {},
      visible: true
    )

    Currency.create!(
      key:    'satoshi',
      code:   'BTC',
      name:   'Bitcoin',
      symbol: '฿',
      type:   'coin',
      base_factor: 100_000_000,
      api_client: 'BTC',
      json_rpc_endpoint: 'http://user:password@127.0.0.1:18332',
      rest_api_endpoint: nil,
      hot_wallet_address: 'unknown',
      wallet_url_template: 'https://blockchain.info/address/#{address}',
      transaction_url_template: 'https://blockchain.info/tx/#{txid}',
      quick_withdraw_limit: 11,
      options: {
        bitgo_test_net:              true,
        bitgo_wallet_id:             nil,
        bitgo_wallet_address:        nil,
        bitgo_wallet_passphrase:     nil,
        bitgo_rest_api_root:         'https://test.bitgo.com/api/v2',
        bitgo_rest_api_access_token: nil
      },
      visible: true
    )

    Currency.create!(
      key:    'ripple',
      code:   'XRP',
      name:   'Ripple',
      symbol: 'ꭆ',
      type:   'coin',
      base_factor: 1_000_000,
      api_client: 'XRP',
      json_rpc_endpoint: 'https://api.altnet.rippletest.net:51234',
      rest_api_endpoint: 'https://api.altnet.rippletest.net:5990',
      hot_wallet_address: 'unknown',
      wallet_url_template: 'https://bithomp.com/explorer/#{address}',
      transaction_url_template: 'https://bithomp.com/explorer/#{txid}',
      quick_withdraw_limit: 10000,
      options: {
        bitgo_test_net:              true,
        bitgo_wallet_id:             nil,
        bitgo_wallet_address:        nil,
        bitgo_wallet_passphrase:     nil,
        bitgo_rest_api_root:         'https://test.bitgo.com/api/v2',
        bitgo_rest_api_access_token: nil
      },
      visible: true
    )
    
    Currency.create!(
      key:    'bitcoin_cash',
      code:   'BCH',
      name:   'Bitcoin Cash',
      symbol: '฿',
      type:   'coin',
      base_factor: 100_000_000,
      api_client: 'BCH',
      json_rpc_endpoint: 'http://user:password@127.0.0.1:18332',
      rest_api_endpoint: nil,
      hot_wallet_address: 'unknown',
      wallet_url_template: 'https://www.blocktrail.com/BCC/address/#{address}',
      transaction_url_template: 'https://www.blocktrail.com/BCC/tx/#{txid}',
      quick_withdraw_limit: 10,
      options: {
        bitgo_test_net:              true,
        bitgo_wallet_id:             nil,
        bitgo_wallet_address:        nil,
        bitgo_wallet_passphrase:     nil,
        bitgo_rest_api_root:         'https://test.bitgo.com/api/v2',
        bitgo_rest_api_access_token: nil
      },
      visible: true
    )
    
    Currency.create!(
      key:    'litoshi',
      code:   'LTC',
      name:   'Litecoin',
      symbol: 'Ł',
      type:   'coin',
      base_factor: 100_000_000,
      api_client: 'LTC',
      json_rpc_endpoint: 'http://user:password@127.0.0.1:18332',
      rest_api_endpoint: nil,
      hot_wallet_address: 'unknown',
      wallet_url_template: 'https://www.blocktrail.com/LTC/address/#{address}',
      transaction_url_template: 'https://www.blocktrail.com/LTC/tx/#{txid}',
      quick_withdraw_limit: 100,
      options: {
        bitgo_test_net:              true,
        bitgo_wallet_id:             nil,
        bitgo_wallet_address:        nil,
        bitgo_wallet_passphrase:     nil,
        bitgo_rest_api_root:         'https://test.bitgo.com/api/v2',
        bitgo_rest_api_access_token: nil
      },
      visible: true
    )

  end
end
