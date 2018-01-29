FactoryBot.define do
  factory :account do
    locked { '0.0'.to_d }
    balance { '100.0'.to_d }
    currency { create(:currency_usd) }

    factory :account_btc do
      currency { create(:currency_btc) }
    end
  end
end
