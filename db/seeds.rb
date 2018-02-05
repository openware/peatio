return if Currency.exists?

Currency.create!(
  key:    'dollar',
  code:   'USD',
  name:   'American Dollar',
  symbol: '$',
  type:   'fiat',
  json_rpc_endpoint: nil,
  rest_api_endpoint: nil,
  hot_wallet_address: 'unknown',
  wallet_url_template: 'https://example.com', #optional
  transaction_url_template: 'https://example.com', #optional
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

# Insert all currencies from currencies.yml
