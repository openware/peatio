FactoryBot.define do
  factory :account do
    locked { '0.0'.to_d }
    balance { '100.0'.to_d }
    currency Peatio.base_fiat_ccy_sym

    factory :account_btc do
      currency :btc
    end
  end
end
