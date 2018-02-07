FactoryBot.define do
  factory :account do
    locked { '0.0'.to_d }
    balance { '100.0'.to_d }
    currency { Currency.usd }

    factory :account_btc do
      currency { Currency.btc }
    end
  end
end
