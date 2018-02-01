FactoryBot.define do
  factory :currency do
    hot_wallet_address 'unknown'
    transaction_url_template 'https://example.com'
    wallet_url_template 'https://example.com'
    options '{}'

    factory :currency_usd do
      key 'dollar'
      code 'usd'
      name 'American Dollar'
      quick_withdraw_limit 10
      hot_wallet_address 'unknown'
    end
    
    factory :currency_btc do
      key 'satoshi'
      code 'btc'
      name 'Bitcoin'
      quick_withdraw_limit 0.1
      json_rpc_endpoint 'http://bitcoinrpc:5gKAgrJv8CQr2CGUhjVbBFLSj29HnE6YGXvfykHJzS3k@127.0.0.1:18332'
    end
    
    factory :currency_pts do
      key 'protoshare'
      code 'pts'
      name 'BitShares'
    end
    
  end
end

# t.string  :key,                      limit: 30, null: false
# t.string  :code,                     limit: 30, null: false
# t.string  :name,                     limit: 30, null: false
# t.string  :symbol,                   limit: 1
# t.string  :type,                     limit: 30, null: false, default: 'coin'
# t.string  :json_rpc_endpoint,        limit: 200
# t.string  :rest_api_endpoint,        limit: 200
# t.string  :hot_wallet_address,       limit: 200, null: false
# t.string  :wallet_url_template,      limit: 200, null: false
# t.string  :transaction_url_template, limit: 200, null: false
# t.decimal :quick_withdraw_limit,     precision: 23, scale: 10, unsigned: true, null: false, default: 0
# t.string  :options,                  limit: 1000, default: '{}', null: false
# t.boolean :visible,                  default: true
# t.timestamps                         null: false
#
#
# - id: 1
#   key: dollar
#   code: usd
#   coin: false
#   quick_withdraw_max: 10
# - id: 2
#   key: satoshi
#   code: btc
#   coin: true
#   precision: 8
#   rpc: http://bitcoinrpc:5gKAgrJv8CQr2CGUhjVbBFLSj29HnE6YGXvfykHJzS3k@127.0.0.1:18332
#   blockchain: http://testnet.btclook.com/txn/#{txid}
#   address_url: https://blockchain.info/address/#{address}
#   quick_withdraw_max: 0.1
# - id: 4
#   key: protoshare
#   code: pts
#   coin: true