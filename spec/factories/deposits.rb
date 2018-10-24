# encoding: UTF-8
# frozen_string_literal: true

FactoryBot.define do
  factory :deposit do
    member { create(:member, :level_3) }
    amount { Kernel.rand(100..10_000).to_d }

    factory :deposit_btc, class: Deposits::Coin do
      currency { Currency.find(:btc) }
      address { Faker::Bitcoin.address }
      txid { Faker::Lorem.characters(64) }
      txout { 0 }
    end

    factory :deposit_usd, class: Deposits::Fiat do
      currency { Currency.find(:usd) }
    end

    trait :deposit_bch do
      type { Deposits::Coin }
      currency { Currency.find(:bch) }
      address { Faker::Bitcoin.address }
      txid { Faker::Lorem.characters(64) }
      txout { 0 }
    end
    factory :deposit_bch, traits: [:deposit_bch]

    trait :deposit_dash do
      type { Deposits::Coin }
      currency { Currency.find(:dash) }
      address { Faker::Bitcoin.address }
      txid { Faker::Lorem.characters(64) }
      txout { 0 }
    end
    factory :deposit_dash, traits: [:deposit_dash]

    trait :deposit_ltc do
      type { Deposits::Coin }
      currency { Currency.find(:ltc) }
      address { Faker::Bitcoin.address }
      txid { Faker::Lorem.characters(64) }
      txout { 0 }
    end
    factory :deposit_ltc, traits: [:deposit_ltc]

    trait :deposit_eth do
      type { Deposits::Coin }
      currency { Currency.find(:eth) }
      member { create(:member, :level_3, :barong) }
      address { Faker::Bitcoin.address }
      txid { Faker::Lorem.characters(64) }
      txout { 0 }
    end
    factory :deposit_eth, traits: [:deposit_eth]

    trait :deposit_trst do
      type { Deposits::Coin }
      currency { Currency.find(:trst) }
      member { create(:member, :level_3, :barong) }
      address { Faker::Bitcoin.address }
      txid { Faker::Lorem.characters(64) }
      txout { 0 }
    end
    factory :deposit_trst, traits: [:deposit_trst]

    trait :deposit_xrp do
      type { Deposits::Coin }
      currency { Currency.find(:xrp) }
      member { create(:member, :level_3, :barong) }
      address { Faker::Bitcoin.address }
      txid { Faker::Lorem.characters(64) }
      txout { 0 }
    end
    factory :deposit_xrp, traits: [:deposit_xrp]
  end
end
