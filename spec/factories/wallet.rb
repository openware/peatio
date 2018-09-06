# encoding: UTF-8
# frozen_string_literal: true

FactoryBot.define do
  factory :wallet do

    trait :eth_deposit do
      currency_id        'eth'
      blockchain_key     'eth-rinkeby'
      name               'Ethereum Deposit Wallet'
      address            '249048804499541338815845805798634312140346616732'
      kind               'deposit'
      max_balance        100.0
      nsig               2
      status             'active'
      gateway            'geth'
      uri                'http://127.0.0.1:8545'
      secret             'changeme'
    end

    trait :eth_hot do
      currency_id        'eth'
      blockchain_key     'eth-rinkeby'
      name               'Ethereum Hot Wallet'
      address            '249048804499541338815845805798634312140346616732'
      kind               'hot'
      max_balance        100.0
      nsig               2
      status             'active'
      gateway            'geth'
      uri                'http://127.0.0.1:8545'
      secret             'changeme'
    end

    trait 'eth_warm' do
      currency_id        'eth'
      blockchain_key     'eth-rinkeby'
      name               'Ethereum Warm Wallet'
      address            '0x2b9fBC10EbAeEc28a8Fc10069C0BC29E45eBEB9C'
      kind               'warm'
      nsig               2
      status             'active'
      gateway            'geth'
      uri                'http://127.0.0.1:8545'
      secret             'changeme'
    end

    trait :trst_deposit do
      currency_id        'trst'
      blockchain_key     'eth-rinkeby'
      name               'Trust Coin Deposit Wallet'
      address            '249048804499541338815845805798634312140346616732'
      kind               'deposit'
      max_balance        100.0
      nsig               2
      status             'active'
      gateway            'geth'
      uri                'http://127.0.0.1:8545'
      secret             'changeme'
    end

    trait :trst_hot do
      currency_id        'trst'
      blockchain_key     'eth-rinkeby'
      name               'Trust Coin Hot Wallet'
      address            '249048804499541338815845805798634312140346616732'
      kind               'hot'
      max_balance        100.0
      nsig               2
      status             'active'
      gateway            'geth'
      uri                'http://127.0.0.1:8545'
      secret             'changeme'
    end

    trait :btc_hot do
      currency_id        'btc'
      blockchain_key     'btc-testnet'
      name               'Bitcoin Hot Wallet'
      address            '0x2b9fBC10EbAeEc28a8Fc10069C0BC29E45eBEB9C'
      kind               'hot'
      nsig               2
      status             'active'
      gateway            'bitcoind'
      uri                'http://127.0.0.1:18332'
      secret             'changeme'
    end

    trait :btc_deposit do
      currency_id        'btc'
      blockchain_key     'btc-testnet'
      name               'Bitcoin Deposit Wallet'
      address            '0x2b9fBC10EbAeEc28a8Fc10069C0BC29E45eBEB9C'
      kind               'deposit'
      nsig               2
      status             'active'
      gateway            'bitcoind'
      uri                'http://127.0.0.1:18332'
      secret             'changeme'
    end

    trait :xrp_hot do
      currency_id        'xrp'
      blockchain_key     'xrp-testnet'
      name               'Ripple Hot Wallet'
      address            'r4kpJtnx4goLYXoRdi7mbkRpZ9Xpx2RyPN'
      kind               'hot'
      nsig               2
      status             'active'
      gateway            'rippled'
      uri                'http://127.0.0.1:5005'
      secret             'changeme'
    end

    trait :bch_deposit do
      currency_id       'bch'
      blockchain_key    'bch-testnet'
      name              'Bitcoincash Deposit Wallet'
      address           'n2stP7w1DpSh7N1PzJh7eGjgCk3eTF3DMC'
      kind              'deposit'
      nsig              1
      status            'active'
      gateway           'bitcoincashd'
      uri               'http://127.0.0.1:18332'
      secret            'changeme'
    end

    trait :bch_hot do
      currency_id       'bch'
      blockchain_key    'bch-testnet'
      name              'Bitcoincash Hot Wallet'
      address           'n2stP7w1DpSh7N1PzJh7eGjgCk3eTF3DMC'
      kind              'hot'
      nsig              1
      status            'active'
      gateway           'bitcoincashd'
      uri               'http://127.0.0.1:18332'
      secret            'changeme'
    end

    trait :dash_deposit do
      currency_id       'dash'
      blockchain_key    'dash-testnet'
      name              'Dash Deposit Wallet'
      address           'yVcZM6oUjfwrREm2CDb9G8BMHwwm5o5UsL'
      kind              'deposit'
      nsig              1
      status            'active'
      gateway           'dashd'
      uri               'http://127.0.0.1:19998'
      secret            'changeme'
    end

    trait :dash_hot do
      currency_id       'dash'
      blockchain_key    'dash-testnet'
      name              'Dash Hot Wallet'
      address           'yVcZM6oUjfwrREm2CDb9G8BMHwwm5o5UsL'
      kind              'hot'
      nsig              1
      status            'active'
      gateway           'dashd'
      uri               'http://127.0.0.1:19998'
      secret            'changeme'
    end

    trait :ltc_deposit do
      currency_id       'ltc'
      blockchain_key    'ltc-testnet'
      name              'Litecoin Deposit Wallet'
      address           'Qc2BM7gp8mKgJPPxLAadLAHteNQwhFwwuf'
      kind              'deposit'
      nsig              1
      status            'active'
      gateway           'litecoind'
      uri               'http://127.0.0.1:19332'
    end

    trait :ltc_hot do
      currency_id       'ltc'
      blockchain_key    'ltc-testnet'
      name              'Litecoin Hot Wallet'
      address           'Qc2BM7gp8mKgJPPxLAadLAHteNQwhFwwuf'
      kind              'hot'
      nsig              1
      status            'active'
      gateway           'litecoind'
      uri               'http://127.0.0.1:19332'
    end
  end
end
