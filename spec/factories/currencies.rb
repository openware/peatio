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

# | currencies | CREATE TABLE `currencies` (
#   `id` int(11) NOT NULL AUTO_INCREMENT,
#   `key` varchar(30) COLLATE utf8_unicode_ci NOT NULL,
#   `code` varchar(30) COLLATE utf8_unicode_ci NOT NULL,
#   `name` varchar(30) COLLATE utf8_unicode_ci NOT NULL,
#   `symbol` varchar(1) COLLATE utf8_unicode_ci DEFAULT NULL,
#   `type` varchar(30) COLLATE utf8_unicode_ci NOT NULL DEFAULT 'coin',
#   `json_rpc_endpoint` varchar(200) COLLATE utf8_unicode_ci DEFAULT NULL,
#   `rest_api_endpoint` varchar(200) COLLATE utf8_unicode_ci DEFAULT NULL,
#   `hot_wallet_address` varchar(200) COLLATE utf8_unicode_ci NOT NULL,
#   `wallet_url_template` varchar(200) COLLATE utf8_unicode_ci NOT NULL,
#   `transaction_url_template` varchar(200) COLLATE utf8_unicode_ci NOT NULL,
#   `quick_withdraw_limit` decimal(23,10) NOT NULL DEFAULT '0.0000000000',
#   `options` varchar(1000) COLLATE utf8_unicode_ci NOT NULL DEFAULT '{}',
#   `visible` tinyint(1) DEFAULT '1',
#   `created_at` datetime NOT NULL,
#   `updated_at` datetime NOT NULL,
#   PRIMARY KEY (`id`)
# ) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci |
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